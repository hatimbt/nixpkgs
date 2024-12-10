{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, libpng, libtiff, zlib, lcms2, jpylyzer
, jpipLibSupport ? false # JPIP library & executables
, jpipServerSupport ? false, curl, fcgi # JPIP Server
, jdk

# for passthru.tests
, ffmpeg
, gdal
, gdcm
, ghostscript
, imagemagick
, leptonica
, mupdf
, poppler
, python3
, vips
}:

let
  mkFlag = optSet: flag: "-D${flag}=${if optSet then "ON" else "OFF"}";
in

stdenv.mkDerivation rec {
  pname = "openjpeg";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "uclouvain";
    repo = "openjpeg";
    rev = "v${version}";
    hash = "sha256-ONPahcQ80e3ahYRQU+Tu8Z7ZTARjRlpXqPAYpUlX5sY=";
  };

  outputs = [ "out" "dev" ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_NAME_DIR=\${CMAKE_INSTALL_PREFIX}/lib"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_CODEC=ON"
    "-DBUILD_THIRDPARTY=OFF"
    (mkFlag jpipLibSupport "BUILD_JPIP")
    (mkFlag jpipServerSupport "BUILD_JPIP_SERVER")
    "-DBUILD_VIEWER=OFF"
    "-DBUILD_JAVA=OFF"
    (mkFlag doCheck "BUILD_TESTING")
  ];

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libpng libtiff zlib lcms2 ]
    ++ lib.optionals jpipServerSupport [ curl fcgi ]
    ++ lib.optional (jpipLibSupport) jdk;

  doCheck = (!stdenv.hostPlatform.isAarch64 && !stdenv.hostPlatform.isPower64); # tests fail on aarch64-linux and powerpc64
  nativeCheckInputs = [ jpylyzer ];
  checkPhase = ''
    substituteInPlace ../tools/ctest_scripts/travis-ci.cmake \
      --replace "JPYLYZER_EXECUTABLE=" "JPYLYZER_EXECUTABLE=\"$(command -v jpylyzer)\" # "
    OPJ_SOURCE_DIR=.. ctest -S ../tools/ctest_scripts/travis-ci.cmake
  '';

  passthru = {
    incDir = "openjpeg-${lib.versions.majorMinor version}";
    tests = {
      ffmpeg = ffmpeg.override { withOpenjpeg = true; };
      imagemagick = imagemagick.override { openjpegSupport = true; };
      pillow = python3.pkgs.pillow;

      inherit
        gdal
        gdcm
        ghostscript
        leptonica
        mupdf
        poppler
        vips
      ;
    };
  };

  meta = with lib; {
    description = "Open-source JPEG 2000 codec written in C language";
    homepage = "https://www.openjpeg.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ codyopel ];
    platforms = platforms.all;
    changelog = "https://github.com/uclouvain/openjpeg/blob/v${version}/CHANGELOG.md";
  };
}
