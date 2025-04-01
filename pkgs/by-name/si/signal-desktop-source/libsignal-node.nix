{
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  npmHooks,
  protobuf,
  clang,
  gitMinimal,
  cmake,
  boringssl,
  runCommand,
  fetchFromGitHub,
  python3,
  nodejs,

}:
let
  # boring-sys expects the static libraries in build/ instead of lib/
  boringssl-wrapper = runCommand "boringssl-wrapper" { } ''
    mkdir $out
    cd $out
    ln -s ${boringssl.out}/lib build
    ln -s ${boringssl.dev}/include include
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libsignal-node";
  version = "0.67.0";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "libsignal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cwra5o9g2+M3dboQUuBikRWyaydL/CGwOfJbImsFRoI=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-KVt4ESHaHDtD+pcaMMG/DMMznYGpWleEf7uTZB45Ud0=";

  npmRoot = "node";
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-npm-deps";
    inherit (finalAttrs) version src;
    sourceRoot = "${finalAttrs.src.name}/${finalAttrs.npmRoot}";
    hash = "sha256-TXRZFfdl86PLJ1FWOkTcXjbx8aZV7gEvs22Pu8b5uFU=";
  };

  nativeBuildInputs = [
    python3
    protobuf
    nodejs
    clang
    gitMinimal
    cmake
    npmHooks.npmConfigHook
    rustPlatform.bindgenHook
  ];
  env.BORING_BSSL_PATH = "${boringssl-wrapper}";
  env.NIX_LDFLAGS = if stdenv.hostPlatform.isDarwin then "-lc++" else "-lstdc++";

  patchPhase = ''
    runHook prePatch

    substituteInPlace node/binding.gyp \
      --replace-fail "'--out-dir', '<(PRODUCT_DIR)/'," \
                     "'--out-dir', '$out/lib/<(NODE_OS_NAME)-<(target_arch)/'," \
      --replace-fail "'target_name': 'libsignal_client_<(NODE_OS_NAME)_<(target_arch).node'," \
                     "'target_name': '@signalapp+libsignal-client',"

    substituteInPlace node/build_node_bridge.py \
      --replace-fail "dst_base = 'libsignal_client_%s_%s' % (node_os_name, node_arch)" \
                     "dst_base = '@signalapp+libsignal-client'"

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    pushd node
    npx node-gyp rebuild
    popd

    runHook postBuild
  '';

  dontCargoInstall = true;
})
