{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  python3Packages,
  Security,

  # tests
  firefox-unwrapped,
  firefox-esr-unwrapped,
  mesa,
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-cbindgen";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "cbindgen";
    rev = "v${version}";
    hash = "sha256-1GT+EgltLhveEACxhY+748L1HIIyQHbEs7wLKANFWr0=";
  };

  cargoHash = "sha256-VaM2+az881qePMqkQRxVxoXCgrgPC8LqSQNDst1bnkY=";

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin Security;

  nativeCheckInputs = [
    cmake
    python3Packages.cython
  ];

  checkFlags =
    [
      # Disable tests that require rust unstable features
      # https://github.com/eqrion/cbindgen/issues/338
      "--skip test_expand"
      "--skip test_bitfield"
      "--skip lib_default_uses_debug_build"
      "--skip lib_explicit_debug_build"
      "--skip lib_explicit_release_build"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # WORKAROUND: test_body fails when using clang
      # https://github.com/eqrion/cbindgen/issues/628
      "--skip test_body"
    ];

  passthru.tests = {
    inherit
      firefox-unwrapped
      firefox-esr-unwrapped
      mesa
      ;
  };

  meta = with lib; {
    changelog = "https://github.com/mozilla/cbindgen/blob/v${version}/CHANGES";
    description = "Project for generating C bindings from Rust code";
    mainProgram = "cbindgen";
    homepage = "https://github.com/mozilla/cbindgen";
    license = licenses.mpl20;
    maintainers = with maintainers; [ hexa ];
  };
}
