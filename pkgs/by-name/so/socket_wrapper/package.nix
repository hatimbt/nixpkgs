{
  lib,
  stdenv,
  fetchurl,
  cmake,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "socket_wrapper";
  version = "1.4.4";

  src = fetchurl {
    url = "mirror://samba/cwrap/socket_wrapper-${version}.tar.gz";
    sha256 = "sha256-KJAALRQ3tvt//cZ8NzTxPQ4r99Y7sJfWA6n24uBdw8g=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  meta = with lib; {
    description = "Library passing all socket communications through unix sockets";
    homepage = "https://git.samba.org/?p=socket_wrapper.git;a=summary;";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
