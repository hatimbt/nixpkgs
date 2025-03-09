{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  wrapQtAppsHook,
  qtbase,
  qtsvg,
  qtwayland,
  alsa-lib,
  pipewire,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qpwgraph";
  version = "0.8.2";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "rncbc";
    repo = "qpwgraph";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-BU57Iprz+kQXybKtR26Qi+3gsLv761hlg4HAnay6hIA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
    alsa-lib
    pipewire
  ];

  cmakeFlags = [ "-DCONFIG_WAYLAND=ON" ];

  meta = with lib; {
    description = "Qt graph manager for PipeWire, similar to QjackCtl";
    longDescription = ''
      qpwgraph is a graph manager dedicated for PipeWire,
      using the Qt C++ framework, based and pretty much like
      the same of QjackCtl.
    '';
    homepage = "https://gitlab.freedesktop.org/rncbc/qpwgraph";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      kanashimia
      exi
      Scrumplex
    ];
    mainProgram = "qpwgraph";
  };
})
