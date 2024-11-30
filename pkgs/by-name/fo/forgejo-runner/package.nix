{ lib
, buildGoModule
, fetchFromGitea
, testers
, forgejo-runner
, nixosTests
}:

let
  # tests which assume network access in some form
  disabledTests = [
    "Test_runCreateRunnerFile"
    "Test_ping"
  ];
in
buildGoModule rec {
  pname = "forgejo-runner";
  version = "5.0.3";

  src = fetchFromGitea {
    domain = "code.forgejo.org";
    owner = "forgejo";
    repo = "runner";
    rev = "v${version}";
    hash = "sha256-c1s2n4s2LY4KvQrPZJpAnXzJCTe6Fbc0cf1plwHZPiA=";
  };

  vendorHash = "sha256-DQcVknodbVlHygJkrGSfVGPKXR9kLGeyivNjYmjtFNs=";

  ldflags = [
    "-s"
    "-w"
    "-X gitea.com/gitea/act_runner/internal/pkg/ver.version=${src.rev}"
  ];

  checkFlags = [
    "-skip ${lib.concatStringsSep "|" disabledTests}"
  ];

  passthru.tests = {
    inherit (nixosTests.forgejo) sqlite3;
    version = testers.testVersion {
      package = forgejo-runner;
      version = src.rev;
    };
  };

  meta = with lib; {
    description = "Runner for Forgejo based on act";
    homepage = "https://code.forgejo.org/forgejo/runner";
    changelog = "https://code.forgejo.org/forgejo/runner/src/tag/${src.rev}/RELEASE-NOTES.md";
    license = licenses.mit;
    maintainers = with maintainers; [ kranzes emilylange ];
    mainProgram = "act_runner";
  };
}
