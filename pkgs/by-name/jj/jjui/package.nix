{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "jjui";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "idursun";
    repo = "jjui";
    tag = "v${version}";
    hash = "sha256-Bao851E1AFTIjGTJrnYc95BWxXnQjWwyufSMQCbiYuU=";
  };

  vendorHash = "sha256-YlOK+NvyH/3uvvFcCZixv2+Y2m26TP8+ohUSdl3ppro=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A TUI for Jujutsu VCS";
    homepage = "https://github.com/idursun/jjui";
    changelog = "https://github.com/idursun/jjui/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      adda
    ];
    mainProgram = "jjui";
  };
}
