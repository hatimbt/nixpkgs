{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, ninja
, pkg-config
, sassc
, gdk-pixbuf
, librsvg
, gtk-engine-murrine
, gitUpdater
}:

stdenv.mkDerivation rec {
  pname = "greybird";
  version = "3.23.3";

  src = fetchFromGitHub {
    owner = "shimmerproject";
    repo = pname;
    rev = "v${version}";
    sha256 = "+MZQ3FThuRFEfoARsF09B7POwytS5RgTs9zYzIHVtfg=";
  };

  patches = [
    # Fix label styles for xfdesktop 4.19
    # https://github.com/shimmerproject/Greybird/pull/338
    (fetchpatch {
      url = "https://github.com/shimmerproject/Greybird/commit/7e4507d7713b2aaf41f8cfef2a1a9e214a4d8b6f.patch";
      hash = "sha256-awXM2RgFIK/Ik5cJSy4IQYl+ic+XGQV0YwbL3SPclzQ=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sassc
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = with lib; {
    description = "Grey and blue theme from the Shimmer Project for GTK-based environments";
    homepage = "https://github.com/shimmerproject/Greybird";
    license = [ licenses.gpl2Plus ]; # or alternatively: cc-by-nc-sa-30 or later
    platforms = platforms.linux;
    maintainers = [ maintainers.romildo ];
  };
}
