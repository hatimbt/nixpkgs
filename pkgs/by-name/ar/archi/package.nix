{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  jdk,
  libsecret,
  glib,
  webkitgtk_4_0,
  wrapGAppsHook3,
  _7zz,
  nixosTests,
}:

stdenv.mkDerivation rec {
  pname = "Archi";
  version = "5.5.0";

  src =
    {
      "x86_64-linux" = fetchurl {
        url = "https://www.archimatetool.com/downloads/archi/${version}/Archi-Linux64-${version}.tgz";
        hash = "sha256-DLYgfYzSsxW4JZfWM+EU8icY+DvMMkvrIkj4NMiNBL0=";
      };
      "x86_64-darwin" = fetchurl {
        url = "https://www.archimatetool.com/downloads/archi/${version}/Archi-Mac-${version}.dmg";
        hash = "sha256-BeQPTsY4pgCsoE4P+dMKE+P3UP+8WiUTbiWFespkzsk=";
      };
      "aarch64-darwin" = fetchurl {
        url = "https://www.archimatetool.com/downloads/archi/${version}/Archi-Mac-Silicon-${version}.dmg";
        hash = "sha256-g5FFgv7w4Hs26GlUXCpV3VQjNrWd355vtxt6FD84DWg=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  buildInputs = [
    libsecret
  ];

  nativeBuildInputs =
    [
      makeWrapper
      wrapGAppsHook3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      _7zz
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ];

  sourceRoot = if stdenv.hostPlatform.isDarwin then "." else null;

  installPhase =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      ''
        mkdir -p $out/bin $out/libexec
        for f in configuration features p2 plugins Archi.ini; do
          cp -r $f $out/libexec
        done

        install -D -m755 Archi $out/libexec/Archi
        makeWrapper $out/libexec/Archi $out/bin/Archi \
          --prefix LD_LIBRARY_PATH : ${
            lib.makeLibraryPath ([
              glib
              webkitgtk_4_0
            ])
          } \
          --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
          --prefix PATH : ${jdk}/bin
      ''
    else
      ''
        mkdir -p "$out/Applications"
        mv Archi.app "$out/Applications/"
      '';

  passthru.updateScript = ./update.sh;

  passthru.tests = { inherit (nixosTests) archi; };

  meta = with lib; {
    description = "ArchiMate modelling toolkit";
    longDescription = ''
      Archi is an open source modelling toolkit to create ArchiMate
      models and sketches.
    '';
    homepage = "https://www.archimatetool.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [
      earldouglas
      paumr
    ];
    mainProgram = "Archi";
  };
}
