{
  lib,
  stdenv,
  meson,
  ninja,
  fetchFromGitHub,
  fetchFromGitLab,
  re2c,
  gperf,
  gawk,
  pkg-config,
  boost,
  fmt,
  luajit_openresty,
  ncurses,
  serd,
  sord,
  libcap,
  liburing,
  openssl,
  cereal,
  cmake,
  asciidoctor,
  makeWrapper,
  versionCheckHook,
  gitUpdater,
  enableIoUring ? false,
  emilua, # this package
}:

let
  trial-protocol-wrap = fetchFromGitHub {
    owner = "breese";
    repo = "trial.protocol";
    rev = "79149f604a49b8dfec57857ca28aaf508069b669";
    sparseCheckout = [
      "include"
    ];
    hash = "sha256-QpQ70KDcJyR67PtOowAF6w48GitMJ700B8HiEwDA5sU=";
    postFetch = ''
      rm $out/*.*
      mkdir -p $out/lib/pkgconfig
      cat > $out/lib/pkgconfig/trial-protocol.pc << EOF
        Name: trial.protocol
        Version: 0-unstable-2023-02-10
        Description:  C++ header-only library with parsers and generators for network wire protocols
        Requires:
        Libs:
        Cflags:
      EOF
    '';
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "emilua";
  version = "0.11.4";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "emilua";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CVEBFySsGT0f16Dim1Pw1GdDM0fWUKieRZyxHaDH3O4=";
  };

  propagatedBuildInputs = [
    luajit_openresty
    boost
    fmt
    ncurses
    serd
    sord
    libcap
    liburing
    openssl
    cereal
    trial-protocol-wrap
  ];

  nativeBuildInputs = [
    re2c
    gperf
    gawk
    pkg-config
    asciidoctor
    meson
    cmake
    ninja
    makeWrapper
  ];

  dontUseCmakeConfigure = true;

  mesonFlags = [
    (lib.mesonBool "enable_io_uring" enableIoUring)
    (lib.mesonBool "enable_file_io" enableIoUring)
    (lib.mesonBool "enable_tests" true)
    (lib.mesonBool "enable_manpages" true)
    (lib.mesonOption "version_suffix" "-nixpkgs1")
  ];

  postPatch = ''
    patchShebangs src/emilua_gperf.awk --interpreter '${lib.getExe gawk} -f'
  '';

  # io_uring is not allowed in Nix sandbox, that breaks the tests
  doCheck = !enableIoUring;

  mesonCheckFlags = [
    # Skipped test: libpsx
    # Known issue with no-new-privs disabled in the Nix build environment.
    "--no-suite"
    "libpsx"
  ];

  postInstall = ''
    mkdir -p $out/nix-support
    cp ${./setup-hook.sh} $out/nix-support/setup-hook
    substituteInPlace $out/nix-support/setup-hook \
      --replace-fail @sitePackages@ "${finalAttrs.passthru.sitePackages}"
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
    inherit boost;
    sitePackages = "lib/emilua-${(lib.concatStringsSep "." (lib.take 2 (lib.splitVersion finalAttrs.version)))}";
    tests.with-io-uring = emilua.override { enableIoUring = true; };
  };

  meta = {
    description = "Lua execution engine";
    mainProgram = "emilua";
    homepage = "https://emilua.org/";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [
      manipuladordedados
      lucasew
    ];
    platforms = lib.platforms.linux;
  };
})
