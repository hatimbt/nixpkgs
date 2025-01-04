args@{
  lib,
  stdenv,
  gcc13Stdenv,
  fetchFromGitHub,
  shared-mime-info,
  autoconf,
  automake,
  intltool,
  libtool,
  pkg-config,
  cmake,
  ruby,
  librsvg,
  ncurses,
  m17n_lib,
  m17n_db,
  expat,
  withAnthy ? true,
  anthy ? null,
  withGtk ? true,
  withGtk2 ? withGtk,
  gtk2 ? null,
  withGtk3 ? withGtk,
  gtk3 ? null,
  # Was never enabled in the history of this package and is not needed by any
  # dependent package, hence disabled to save up closure size.
  withQt ? false,
  withQt5 ? withQt,
  qt5 ? null,
  withLibnotify ? true,
  libnotify ? null,
  withSqlite ? true,
  sqlite ? null,
  withNetworking ? true,
  curl ? null,
  openssl ? null,
  withFFI ? true,
  libffi ? null,

  # Things that are clearly an overkill to be enabled by default
  withMisc ? false,
  libeb ? null,
}:

assert withGtk2 -> gtk2 != null;
assert withGtk3 -> gtk3 != null;

assert withAnthy -> anthy != null;
assert withLibnotify -> libnotify != null;
assert withSqlite -> sqlite != null;
assert withNetworking -> curl != null && openssl != null;
assert withFFI -> libffi != null;
assert withMisc -> libeb != null;

let
  stdenv = if args.stdenv.cc.isGNU then args.gcc13Stdenv else args.stdenv;
in

stdenv.mkDerivation rec {
  version = "1.8.9";
  pname = "uim";

  src = fetchFromGitHub {
    owner = "uim";
    repo = "uim";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-OqbtuoV9xPg51BhboP4EtTZA2psd8sUk3l3RfvYtv3w=";
  };

  nativeBuildInputs =
    [
      autoconf
      automake
      intltool
      libtool
      pkg-config
      cmake

      ruby # used by sigscheme build to generate function tables
      librsvg # used by uim build to generate png pixmaps from svg
    ]
    ++ lib.optionals withQt5 [
      qt5.wrapQtAppsHook
    ];

  buildInputs =
    [
      ncurses
      m17n_lib
      m17n_db
      expat
    ]
    ++ lib.optional withAnthy anthy
    ++ lib.optional withGtk2 gtk2
    ++ lib.optional withGtk3 gtk3
    ++ lib.optionals withQt5 [
      qt5.qtbase
      qt5.qtx11extras
    ]
    ++ lib.optional withLibnotify libnotify
    ++ lib.optional withSqlite sqlite
    ++ lib.optionals withNetworking [
      curl
      openssl
    ]
    ++ lib.optional withFFI libffi
    ++ lib.optional withMisc libeb;

  prePatch = ''
    patchShebangs *.sh */*.sh */*/*.sh

    # configure sigscheme in maintainer mode or else some function tables won't get autogenerated
    substituteInPlace configure.ac \
      --replace "--with-master-pkg=uim --enable-conf=uim" \
                "--enable-maintainer-mode --with-master-pkg=uim --enable-conf=uim"

    # generate ./configure files
    (cd sigscheme/libgcroots; ./autogen.sh)
    (cd sigscheme; ./autogen.sh)
    ./autogen.sh
  '';

  patches = [
    ./data-hook.patch
  ];

  configureFlags =
    [
      # configure in maintainer mode or else some pixmaps won't get autogenerated
      # this should imply the above `--enable-maintainer-mode`, but it does not
      "--enable-maintainer-mode"

      "--enable-pref"
      "--with-skk"
      "--with-x"
      "--with-xft"
      "--with-expat=${expat.dev}"
    ]
    ++ lib.optional withAnthy "--with-anthy-utf8"
    ++ lib.optional withGtk2 "--with-gtk2"
    ++ lib.optional withGtk3 "--with-gtk3"
    ++ lib.optionals withQt5 [
      "--with-qt5"
      "--with-qt5-immodule"
    ]
    ++ lib.optional withLibnotify "--enable-notify=libnotify"
    ++ lib.optional withSqlite "--with-sqlite3"
    ++ lib.optionals withNetworking [
      "--with-curl"
      "--with-openssl-dir=${openssl.dev}"
    ]
    ++ lib.optional withFFI "--with-ffi"
    ++ lib.optional withMisc "--with-eb";

  # TODO: things in `./configure --help`, but not in nixpkgs
  #--with-canna            Use Canna [default=no]
  #--with-wnn              Build with libwnn [default=no]
  #--with-mana             Build a plugin for Mana [default=yes]
  #--with-prime            Build a plugin for PRIME [default=yes]
  #--with-sj3              Use SJ3 [default=no]
  #--with-osx-dcs          Build with OS X Dictionary Services [default=no]

  # TODO: fix this in librsvg/glib later
  # https://github.com/NixOS/nixpkgs/pull/57027#issuecomment-475461733
  preBuild = ''
    export XDG_DATA_DIRS="${shared-mime-info}/share"
  '';

  enableParallelBuilding = false;

  dontUseCmakeConfigure = true;

  meta = with lib; {
    homepage = src.meta.homepage;
    description = "Multilingual input method framework";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [
      ericsagnes
      oxij
    ];
  };
}
