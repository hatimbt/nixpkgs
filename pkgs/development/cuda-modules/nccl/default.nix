# NOTE: Though NCCL is called within the cudaPackages package set, we avoid passing in
# the names of dependencies from that package set directly to avoid evaluation errors
# in the case redistributable packages are not available.
{
  lib,
  fetchFromGitHub,
  python3,
  which,
  autoAddDriverRunpath,
  cudaPackages,
  # passthru.updateScript
  gitUpdater,
}:
let
  inherit (cudaPackages)
    backendStdenv
    cuda_cccl
    cuda_cudart
    cuda_nvcc
    cudaAtLeast
    cudaFlags
    cudaOlder
    cudatoolkit
    ;
  # versions 2.26+ with CUDA 11.x error with
  # fatal error: cuda/atomic: No such file or directory
  version = if cudaAtLeast "12.0" then "2.26.2-1" else "2.25.1-1";
  hash =
    if cudaAtLeast "12.0" then
      "sha256-iLEuru3gaNLcAdH4V8VIv3gjdTGjgb2/Mr5UKOh69N4="
    else
      "sha256-3snh0xdL9I5BYqdbqdl+noizJoI38mZRVOJChgEE1I8=";
in
backendStdenv.mkDerivation (finalAttrs: {
  pname = "nccl";
  version = version;

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "nccl";
    rev = "v${finalAttrs.version}";
    hash = hash;
  };

  __structuredAttrs = true;
  strictDeps = true;

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs =
    [
      which
      autoAddDriverRunpath
      python3
    ]
    ++ lib.optionals (cudaOlder "11.4") [ cudatoolkit ]
    ++ lib.optionals (cudaAtLeast "11.4") [ cuda_nvcc ];

  buildInputs =
    lib.optionals (cudaOlder "11.4") [ cudatoolkit ]
    ++ lib.optionals (cudaAtLeast "11.4") [
      cuda_nvcc # crt/host_config.h
      cuda_cudart
    ]
    # NOTE: CUDA versions in Nixpkgs only use a major and minor version. When we do comparisons
    # against other version, like below, it's important that we use the same format. Otherwise,
    # we'll get incorrect results.
    # For example, lib.versionAtLeast "12.0" "12.0.0" == false.
    ++ lib.optionals (cudaAtLeast "12.0") [ cuda_cccl ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-unused-function" ];

  postPatch =
    ''
      patchShebangs ./src/device/generate.py
    ''
    # CUDA 12.8 uses GCC 14 and we need to bump C++ standard to C++14
    # in order to work with new constexpr handling
    + lib.optionalString (cudaAtLeast "12.8") ''
      substituteInPlace ./makefiles/common.mk \
        --replace-fail "-std=c++11" "-std=c++14"
    '';

  makeFlags =
    [
      "PREFIX=$(out)"
      "NVCC_GENCODE=${cudaFlags.gencodeString}"
    ]
    ++ lib.optionals (cudaOlder "11.4") [
      "CUDA_HOME=${cudatoolkit}"
      "CUDA_LIB=${lib.getLib cudatoolkit}/lib"
      "CUDA_INC=${lib.getDev cudatoolkit}/include"
    ]
    ++ lib.optionals (cudaAtLeast "11.4") [
      "CUDA_HOME=${cuda_nvcc}"
      "CUDA_LIB=${lib.getLib cuda_cudart}/lib"
      "CUDA_INC=${lib.getDev cuda_cudart}/include"
    ];

  enableParallelBuilding = true;

  postFixup = ''
    moveToOutput lib/libnccl_static.a $dev
  '';

  passthru.updateScript = gitUpdater {
    inherit (finalAttrs) pname version;
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Multi-GPU and multi-node collective communication primitives for NVIDIA GPUs";
    homepage = "https://developer.nvidia.com/nccl";
    license = licenses.bsd3;
    platforms = platforms.linux;
    # NCCL is not supported on Jetson, because it does not use NVLink or PCI-e for inter-GPU communication.
    # https://forums.developer.nvidia.com/t/can-jetson-orin-support-nccl/232845/9
    badPlatforms = lib.optionals cudaFlags.isJetsonBuild [ "aarch64-linux" ];
    maintainers =
      with maintainers;
      [
        mdaiter
        orivej
      ]
      ++ teams.cuda.members;
  };
})
