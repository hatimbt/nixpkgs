{
  stdenv,
  lib,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  gnome,
  gtk3,
  wrapGAppsHook3,
  librsvg,
  libgnome-games-support,
  gettext,
  itstool,
  libxml2,
  python3,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "five-or-more";
  version = "48.0";

  src = fetchurl {
    url = "mirror://gnome/sources/five-or-more/${lib.versions.major finalAttrs.version}/five-or-more-${finalAttrs.version}.tar.xz";
    hash = "sha256-3/w3XAcVC8igBc+nTA6PC6UevLAoVkgiyxH+z9WZrnQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    libxml2
    python3
    wrapGAppsHook3
    vala
  ];

  buildInputs = [
    gtk3
    librsvg
    libgnome-games-support
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "five-or-more";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/five-or-more";
    description = "Remove colored balls from the board by forming lines";
    mainProgram = "five-or-more";
    maintainers = teams.gnome.members;
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
})
