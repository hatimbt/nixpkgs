{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf_26,
}:

rustPlatform.buildRustPackage rec {
  pname = "amazon-q-cli";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "amazon-q-developer-cli";
    tag = "v${version}";
    hash = "sha256-Hi0klNNxtWlZvcqobb8Y2hLsw/Pck1YQZB4AYBmcNKI=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-XK6B2OTCnWMow3KHWU6OK1HsyQW7apcLoYRP7viTte0=";

  cargoBuildFlags = [
    "-p"
    "q_cli"
  ];
  cargoTestFlags = [
    "-p"
    "q_cli"
  ];

  # skip integration tests that have external dependencies
  checkFlags = [
    "--skip=cli::chat::tests::test_flow"
    "--skip=cli::init::tests::test_prompts"
    "--skip=debug_get_index"
    "--skip=debug_list_intellij_variants"
    "--skip=debug_refresh_auth_token"
    "--skip=local_state_all"
    "--skip=local_state_get"
    "--skip=settings_all"
    "--skip=settings_get"
    "--skip=user_whoami"
    "--skip=init_lint_bash_post_bash_profile"
    "--skip=init_lint_bash_post_bashrc"
    "--skip=init_lint_bash_pre_bash_profile"
    "--skip=init_lint_bash_pre_bashrc"
    "--skip=init_lint_fish_pre_00_fig_pre"
    "--skip=init_lint_zsh_post_zprofile"
    "--skip=init_lint_zsh_post_zshrc"
    "--skip=init_lint_zsh_pre_zprofile"
    "--skip=init_lint_zsh_pre_zshrc"
  ];

  nativeBuildInputs = [
    protobuf_26
  ];

  postInstall = ''
    mv $out/bin/q_cli $out/bin/amazon-q
  '';

  meta = {
    description = "Amazon Q Developer AI coding agent CLI";
    homepage = "https://github.com/aws/amazon-q-developer-cli";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ lib.maintainers.jamesward ];
    platforms = lib.platforms.linux;
  };
}
