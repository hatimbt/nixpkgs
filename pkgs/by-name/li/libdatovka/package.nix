{
  lib,
  stdenv,
  autoreconfHook,
  pkg-config,
  fetchurl,
  expat,
  gpgme,
  libgcrypt,
  libxml2,
  libxslt,
  gnutls,
  curl,
  docbook_xsl,
}:

stdenv.mkDerivation rec {
  pname = "libdatovka";
  version = "0.7.1";

  src = fetchurl {
    url = "https://gitlab.nic.cz/datovka/libdatovka/-/archive/v${version}/libdatovka-v${version}.tar.gz";
    sha256 = "sha256-qVbSxPLYe+PjGwRH2U/V2Ku2X1fRPbDOUjFamCsYVgY=";
  };

  patches = [
    ./libdatovka-deprecated-fn-curl.patch
  ];

  configureFlags = [
    "--with-docbook-xsl-stylesheets=${docbook_xsl}/xml/xsl/docbook"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];
  buildInputs = [
    expat
    gpgme
    libgcrypt
    libxml2
    libxslt
    gnutls
    curl
    docbook_xsl
  ];

  meta = with lib; {
    description = "Client library for accessing SOAP services of Czech government-provided Databox infomation system";
    homepage = "https://gitlab.nic.cz/datovka/libdatovka";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.ovlach ];
    platforms = platforms.linux;
  };
}
