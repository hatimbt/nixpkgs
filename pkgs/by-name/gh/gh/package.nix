{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  stdenv,
  testers,
  gh,
}:

buildGoModule rec {
  pname = "gh";
  version = "2.66.0";

  src = fetchFromGitHub {
    owner = "cli";
    repo = "cli";
    tag = "v${version}";
    hash = "sha256-6IxXbi0vWb/AT64q5aZiV1wuz5viksXdxonLfJlu3y0=";
  };

  vendorHash = "sha256-gLFPr6b9zkkvmhcljnuB23MAMa9xELsUHtcP8xTfWFE=";

  nativeBuildInputs = [ installShellFiles ];

  buildPhase = ''
    runHook preBuild
    make GO_LDFLAGS="-s -w" GH_VERSION=${version} bin/gh ${lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) "manpages"}
    runHook postBuild
  '';

  installPhase =
    ''
      runHook preInstall
      install -Dm755 bin/gh -t $out/bin
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installManPage share/man/*/*.[1-9]

      installShellCompletion --cmd gh \
        --bash <($out/bin/gh completion -s bash) \
        --fish <($out/bin/gh completion -s fish) \
        --zsh <($out/bin/gh completion -s zsh)
    ''
    + ''
      runHook postInstall
    '';

  # most tests require network access
  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = gh;
  };

  meta = with lib; {
    description = "GitHub CLI tool";
    homepage = "https://cli.github.com/";
    changelog = "https://github.com/cli/cli/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "gh";
    maintainers = with maintainers; [ zowoq ];
  };
}
