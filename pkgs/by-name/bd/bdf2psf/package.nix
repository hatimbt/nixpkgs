{
  lib,
  stdenv,
  fetchurl,
  perl,
  dpkg,
}:

stdenv.mkDerivation rec {
  pname = "bdf2psf";
  version = "1.230";

  src = fetchurl {
    url = "mirror://debian/pool/main/c/console-setup/bdf2psf_${version}_all.deb";
    sha256 = "sha256-W7eFrzuDcjm9P2hAP7+u9YPIhCqF3pbWb9+ynmKjs5M=";
  };

  nativeBuildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    substituteInPlace usr/bin/bdf2psf --replace /usr/bin/perl "${perl}/bin/perl"
    rm usr/share/doc/bdf2psf/changelog.gz
    mv usr "$out"
    runHook postInstall
  '';

  meta = with lib; {
    description = "BDF to PSF converter";
    homepage = "https://packages.debian.org/sid/bdf2psf";
    longDescription = ''
      Font converter to generate console fonts from BDF source fonts
    '';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ rnhmjoj ];
    platforms = platforms.all;
    mainProgram = "bdf2psf";
  };
}
