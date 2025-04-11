{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  just,
  libcosmicAppHook,
  which,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-notifications";
  version = "1.0.0-alpha.6";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-notifications";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-d6bAiRSO2opKSZfadyQYrU9oIrXwPNzO/g2E2RY6q04=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-utip7E8NST88mPaKppkuOcdW+QkFoRqWy3a2McvMHo8=";

  postPatch = ''
    substituteInPlace justfile --replace-fail '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [
    just
    which
    libcosmicAppHook
  ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-notifications"
  ];

  passthru.tests = {
    inherit (nixosTests)
      cosmic
      cosmic-autologin
      cosmic-noxwayland
      cosmic-autologin-noxwayland
      ;
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-notifications";
    description = "Notifications for the COSMIC Desktop Environment";
    mainProgram = "cosmic-notifications";
    license = lib.licenses.gpl3Only;
    maintainers = lib.teams.cosmic.members;
    platforms = lib.platforms.linux;
  };
})
