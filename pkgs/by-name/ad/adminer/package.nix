{
  lib,
  stdenv,
  fetchurl,
  php,
  nix-update-script,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "5.1.1";
  pname = "adminer";

  # not using fetchFromGitHub as the git repo relies on submodules that are included in the tar file
  src = fetchurl {
    url = "https://github.com/vrana/adminer/releases/download/v${finalAttrs.version}/adminer-${finalAttrs.version}.zip";
    hash = "sha256-L1akLFljp4UW/YEVLi317ijY62WN9L4g+OQ127vUP/4=";
  };

  nativeBuildInputs = [
    php
    php.packages.composer
    unzip
  ];

  buildPhase = ''
    runHook preBuild

    composer --no-cache run compile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp adminer-${finalAttrs.version}.php $out/adminer.php

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Database management in a single PHP file";
    homepage = "https://www.adminer.org";
    license = with licenses; [
      asl20
      gpl2Only
    ];
    maintainers = with maintainers; [
      jtojnar
      sstef
    ];
    platforms = platforms.all;
  };
})
