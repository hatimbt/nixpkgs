{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "goda";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "loov";
    repo = "goda";
    rev = "v${version}";
    hash = "sha256-UeXn+JAR4TExZahwFozjbwXHF3QEcJvh5SzU/8VAmLg=";
  };

  vendorHash = "sha256-FYjlOYB0L4l6gF8hYtJroV1qMQD0ZmKWXBarjyConRs=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/loov/goda";
    description = "Go Dependency Analysis toolkit";
    maintainers = with maintainers; [ michaeladler ];
    license = licenses.mit;
    mainProgram = "goda";
  };
}
