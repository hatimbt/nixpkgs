{
  lib,
  stdenv,
  fetchurl,
  gawk,
  git,
  gnugrep,
  installShellFiles,
  jre,
  makeWrapper,
  testers,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "crowdin-cli";
  version = "4.5.2";

  src = fetchurl {
    url = "https://github.com/crowdin/crowdin-cli/releases/download/${finalAttrs.version}/crowdin-cli.zip";
    hash = "sha256-gg9cBN0N4KGHW6i56uO5+UE1YJFMa2aQ8nJV8JPSvmU=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    install -D crowdin-cli.jar $out/lib/crowdin-cli.jar

    installShellCompletion --cmd crowdin --bash ./crowdin_completion

    makeWrapper ${jre}/bin/java $out/bin/crowdin \
      --argv0 crowdin \
      --add-flags "-jar $out/lib/crowdin-cli.jar" \
      --prefix PATH : ${
        lib.makeBinPath [
          gawk
          gnugrep
          git
        ]
      }

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = with lib; {
    mainProgram = "crowdin";
    homepage = "https://github.com/crowdin/crowdin-cli/";
    description = "Command-line client for the Crowdin API";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.mit;
    maintainers = with maintainers; [ DamienCassou ];
  };
})
