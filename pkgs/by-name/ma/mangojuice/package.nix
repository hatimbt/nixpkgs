{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  vala,
  pkg-config,
  makeBinaryWrapper,
  replaceVars,

  gtk4,
  libadwaita,
  glib,
  libgee,
  pciutils,
  wrapGAppsHook4,

  mangohud,
  mesa-demos,
  vulkan-tools,
  vkbasalt,

  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mangojuice";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "radiolamp";
    repo = "mangojuice";
    tag = finalAttrs.version;
    hash = "sha256-NpNsYwktcce9R1LpoIL2vh5UzsgDqdPyS0D3mhM3F0w=";
  };

  patches = [
    (replaceVars ./fix-vkbasalt-path.patch {
      vkbasalt = lib.getLib vkbasalt + "/lib/vkbasalt/libvkbasalt.so";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    glib # For glib-compile-schemas
    vala
    pkg-config
    makeBinaryWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    libgee
  ];

  strictDeps = true;
  dontWrapGApps = true;

  postFixup =
    let
      path = lib.makeBinPath [
        mangohud
        mesa-demos # glxgears
        pciutils # lspci
        vulkan-tools # vkcube
      ];
    in
    ''
      wrapProgram $out/bin/mangojuice \
        --prefix PATH : ${path} \
        "''${gappsWrapperArgs[@]}"
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convenient alternative to GOverlay for setting up MangoHud";
    homepage = "https://github.com/radiolamp/mangojuice";
    license = with lib.licenses; [ gpl3Only ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      pluiedev
      getchoo
    ];
  };
})
