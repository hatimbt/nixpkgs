{
  lib,
  mkKdeDerivation,
  replaceVars,
  dbus,
  fontconfig,
  xorg,
  lsof,
  pkg-config,
  spirv-tools,
  qtpositioning,
  qtsvg,
  qtwayland,
  libcanberra,
  libqalculate,
  pipewire,
  qttools,
  qqc2-breeze-style,
  gpsd,
  fetchpatch,
}:
mkKdeDerivation {
  pname = "plasma-workspace";

  patches = [
    (replaceVars ./dependency-paths.patch {
      dbusSend = lib.getExe' dbus "dbus-send";
      fcMatch = lib.getExe' fontconfig "fc-match";
      lsof = lib.getExe lsof;
      qdbus = lib.getExe' qttools "qdbus";
      xmessage = lib.getExe xorg.xmessage;
      xrdb = lib.getExe xorg.xrdb;
      # @QtBinariesDir@ only appears in the *removed* lines of the diff
      QtBinariesDir = null;
    })

    # Backport patch recommended by upstream
    # FIXME: remove in 6.3.5
    (fetchpatch {
      url = "https://invent.kde.org/plasma/plasma-workspace/-/commit/47d502353720004fa2d0e7b0065994b75b3e0ded.patch";
      hash = "sha256-wt0ZIF4zcEOmP0o4ZcjBYxVjr2hVUlOKVJ8SMNSYt68=";
    })
  ];

  postInstall = ''
    # Prevent patching this shell file, it only is used by sourcing it from /bin/sh.
    chmod -x $out/libexec/plasma-sourceenv.sh
  '';

  extraNativeBuildInputs = [
    pkg-config
    spirv-tools
  ];
  extraBuildInputs = [
    qtpositioning
    qtsvg
    qtwayland

    qqc2-breeze-style

    libcanberra
    libqalculate
    pipewire

    xorg.libSM
    xorg.libXcursor
    xorg.libXtst
    xorg.libXft

    gpsd
  ];

  qtWrapperArgs = [ "--inherit-argv0" ];

  # Hardcoded as QStrings, which are UTF-16 so Nix can't pick these up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${lsof} ${xorg.xmessage} ${xorg.xrdb}" > $out/nix-support/depends
  '';

  passthru.providedSessions = [
    "plasma"
    "plasmax11"
  ];
}
