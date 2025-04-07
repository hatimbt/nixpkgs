{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nixosTests,
  alsa-lib,
  SDL2,
  libiconv,
  CoreAudio,
  CoreMIDI,
  CoreServices,
  Cocoa,
}:

stdenv.mkDerivation rec {
  pname = "ft2-clone";
  version = "1.95";

  src = fetchFromGitHub {
    owner = "8bitbubsy";
    repo = "ft2-clone";
    tag = "v${version}";
    hash = "sha256-Xb4LHoon56P6OmHvd7RkODrOc4MDa0+U8npypGhcyw4=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs =
    [ SDL2 ]
    ++ lib.optional stdenv.hostPlatform.isLinux alsa-lib
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
      CoreAudio
      CoreMIDI
      CoreServices
      Cocoa
    ];

  passthru.tests = {
    ft2-clone-starts = nixosTests.ft2-clone;
  };

  meta = with lib; {
    description = "Highly accurate clone of the classic Fasttracker II software for MS-DOS";
    homepage = "https://16-bits.org/ft2.php";
    license = licenses.bsd3;
    maintainers = with maintainers; [ fgaz ];
    # From HOW-TO-COMPILE.txt:
    # > This code is NOT big-endian compatible
    platforms = platforms.littleEndian;
    mainProgram = "ft2-clone";
  };
}
