{
  stdenv,
  lib,
  fetchurl,
  replaceVars,
  bubblewrap,
  cairo,
  cargo,
  gettext,
  git,
  gnome,
  gtk4,
  lcms2,
  libheif,
  libjxl,
  librsvg,
  libseccomp,
  libxml2,
  meson,
  ninja,
  pkg-config,
  rustc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glycin-loaders";
  version = "1.2.0";

  src = fetchurl {
    url = "mirror://gnome/sources/glycin/${lib.versions.majorMinor finalAttrs.version}/glycin-${finalAttrs.version}.tar.xz";
    hash = "sha256-FqtKSDmGOe9wHHw+J6LTEHWzDg3K8/FlLJB7GI9CkNA=";
  };

  patches = [
    # Fix paths in glycin library.
    # Not actually needed for this package since we are only building loaders
    # and this patch is relevant just to apps that use the loaders
    # but apply it here to ensure the patch continues to apply.
    finalAttrs.passthru.glycinPathsPatch
  ];

  nativeBuildInputs = [
    cargo
    gettext # for msgfmt
    git
    meson
    ninja
    pkg-config
    rustc
  ];

  buildInputs = [
    gtk4 # for GdkTexture
    cairo
    lcms2
    libheif
    libxml2 # for librsvg crate
    librsvg
    libseccomp
    libjxl
  ];

  mesonFlags = [
    "-Dglycin-loaders=true"
    "-Dlibglycin=false"
    "-Dvapi=false"
  ];

  strictDeps = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "glycin-loaders";
      packageName = "glycin";
    };

    glycinPathsPatch = replaceVars ./fix-glycin-paths.patch {
      bwrap = "${bubblewrap}/bin/bwrap";
    };
  };

  meta = with lib; {
    description = "Glycin loaders for several formats";
    homepage = "https://gitlab.gnome.org/sophie-h/glycin";
    maintainers = teams.gnome.members;
    license = with licenses; [
      mpl20 # or
      lgpl21Plus
    ];
    platforms = platforms.linux;
  };
})
