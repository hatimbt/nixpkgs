# The standard set of gems in nixpkgs including potential fixes.
#
# The gemset is derived from two points of entry:
# - An attrset describing a gem, including version, source and dependencies
#   This is just meta data, most probably automatically generated by a tool
#   like Bundix (https://github.com/aflatter/bundix).
#   {
#     name = "bundler";
#     version = "1.6.5";
#     sha256 = "1s4x0f5by9xs2y24jk6krq5ky7ffkzmxgr4z1nhdykdmpsi2zd0l";
#     dependencies = [ "rake" ];
#   }
# - An optional derivation that may override how the gem is built. For popular
#   gems that don't behave correctly, fixes are already provided in the form of
#   derivations.
#
# This separates "what to build" (the exact gem versions) from "how to build"
# (to make gems behave if necessary).

{ lib, fetchurl, fetchpatch, fetchpatch2, writeScript, ruby, libkrb5, libxml2, libxslt, python2, stdenv, which
, libiconv, libpq, nodejs, clang, sqlite, zlib, imagemagick, lasem
, pkg-config , ncurses, xapian, gpgme, util-linux, tzdata, icu, libffi
, cmake, libssh2, openssl, openssl_1_1, libmysqlclient, git, perl, pcre2, gecode_3, curl
, libsodium, snappy, libossp_uuid, lxc, libpcap, xorg, gtk3, lerc, buildRubyGem
, cairo, expat, re2, rake, gobject-introspection, gdk-pixbuf, zeromq, czmq, graphicsmagick, libcxx
, file, libvirt, glib, vips, taglib_1, libopus, linux-pam, libidn, protobuf, fribidi, harfbuzz
, bison, flex, pango, python3, patchelf, binutils, freetds, wrapGAppsHook3, atk
, bundler, libsass, dart-sass, libexif, libselinux, libsepol, shared-mime-info, libthai, libdatrie
, CoreServices, DarwinTools, cctools, libtool, discount, exiv2, libepoxy, libxkbcommon, libmaxminddb, libyaml
, cargo, rustc, rustPlatform, libsysprof-capture, imlib2
, autoSignDarwinBinariesHook
}@args:

let
  rainbow_rake = buildRubyGem {
    pname = "rake";
    gemName = "rake";
    source.sha256 = "01j8fc9bqjnrsxbppncai05h43315vmz9fwg28qdsgcjw9ck1d7n";
    type = "gem";
    version = "12.0.0";
  };
in

{
  ZenTest = attrs: {
    meta.mainProgram = "zentest";
  };

  atk = attrs: {
    dependencies = attrs.dependencies ++ [ "gobject-introspection" ];
    nativeBuildInputs = [ rake bundler pkg-config ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    propagatedBuildInputs = [ gobject-introspection wrapGAppsHook3 atk ];
  };

  bundler = attrs:
    let
      templates = "${attrs.ruby.gemPath}/gems/${attrs.gemName}-${attrs.version}/lib/bundler/templates/";
    in {
      # patching shebangs would fail on the templates/Executable file, so we
      # temporarily remove the executable flag.
      preFixup  = "chmod -x $out/${templates}/Executable";
      postFixup = ''
        chmod +x $out/${templates}/Executable

        # Allows to load another bundler version
        sed -i -e "s/activate_bin_path/bin_path/g" $out/bin/bundle
      '';
    };

  cairo = attrs: {
    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    buildInputs = [ cairo expat glib libsysprof-capture pcre2 xorg.libpthreadstubs xorg.libXdmcp ];
  };

  cairo-gobject = attrs: {
    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    buildInputs = [ cairo expat libsysprof-capture pcre2 xorg.libpthreadstubs xorg.libXdmcp ];
  };

  charlock_holmes = attrs: {
    buildInputs = [ which icu zlib ];
  };

  cld3 = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ protobuf ];
  };

  cocoapods-acknowledgements = attrs: {
    dependencies = attrs.dependencies ++ [ "cocoapods" ];
  };

  cocoapods-deploy = attrs: {
    dependencies = [ "cocoapods" ];
  };

  cocoapods-disable-podfile-validations = attrs: {
    dependencies = [ "cocoapods" ];
  };

  cocoapods-generate = attrs: {
    dependencies = attrs.dependencies ++ [ "cocoapods" ];
  };

  cocoapods-git_url_rewriter = attrs: {
    dependencies = [ "cocoapods" ];
  };

  cocoapods-keys = attrs: {
    dependencies = attrs.dependencies ++ [ "cocoapods" ];
  };

  cocoapods-open = attrs: {
    dependencies = [ "cocoapods" ];
  };

  cocoapods-try-release-fix = attrs: {
    dependencies = [ "cocoapods" ];
  };

  curb = attrs: {
    buildInputs = [ curl ];
  };

  curses = attrs: {
    dontBuild = false;
    buildInputs = [ ncurses ];
    patches = lib.optionals (lib.versionOlder attrs.version "1.4.5") [
      # Fixes incompatible function pointer type error with clang 16. Fixed in 1.4.5 and newer.
      # Upstream issue: https://github.com/ruby/curses/issues/85
      (fetchpatch2 {
        url = "https://github.com/ruby/curses/commit/13e00d07c3aaed83d5f138cf268cc33c9f025d0e.patch?full_index=1";
        hash = "sha256-ZJ2egqj3Uwmi4KrF79dtwczpwUqFCp52/xQYUymYDmc=";
      })
    ];
  };

  dep-selector-libgecode = attrs: {
    USE_SYSTEM_GECODE = true;
    postInstall = ''
      installPath=$(cat $out/nix-support/gem-meta/install-path)
      sed -i $installPath/lib/dep-selector-libgecode.rb -e 's@VENDORED_GECODE_DIR =.*@VENDORED_GECODE_DIR = "${gecode_3}"@'
    '';
  };

  digest-sha3 = attrs: {
    hardeningDisable = [ "format" ];
  };

  rdiscount = attrs: {
    # Use discount from nixpkgs instead of vendored version
    dontBuild = false;
    buildInputs = [ discount ];
    patches = [
      # Adapted from Debian:
      # https://sources.debian.org/data/main/r/ruby-rdiscount/2.1.8-1/debian/patches/01_use-system-libmarkdown.patch
      ./rdiscount-use-nixpkgs-libmarkdown.patch
    ];
  };

  ethon = attrs: {
    dontBuild = false;
    postPatch = ''
      substituteInPlace lib/ethon/curls/settings.rb \
        --replace "libcurl" "${curl.out}/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary}"
    '';
  };

  exiv2 = attrs: {
    buildFlags = [ "--with-exiv2-lib=${exiv2}/lib" "--with-exiv2-include=${exiv2.dev}/include" ];
  };

  fog-dnsimple = attrs:
    lib.optionalAttrs (lib.versionOlder attrs.version "1.0.1") {
      postInstall = ''
        cd $(cat $out/nix-support/gem-meta/install-path)
        rm {$out/bin,bin,../../bin}/{setup,console}
      '';
    };

  redis-rack = attrs: {
    dontBuild = false;
    preBuild = ''
      exec 3>&1
      output="$(gem build $gemspec | tee >(cat - >&3))"
      exec 3>&-
      sed -i 's!"rake".freeze!!' $gemspec
    '';
  };

  ffi-rzmq-core = attrs: {
    postInstall = ''
      installPath=$(cat $out/nix-support/gem-meta/install-path)
      sed -i $installPath/lib/ffi-rzmq-core/libzmq.rb -e 's@inside_gem =.*@inside_gem = "${zeromq}/lib"@'
    '';
  };

  mimemagic = attrs: {
    FREEDESKTOP_MIME_TYPES_PATH = "${shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  };

  mini_magick = attrs: {
    postInstall = ''
      installPath=$(cat $out/nix-support/gem-meta/install-path)
      echo -e "\nENV['PATH'] += ':${graphicsmagick}/bin'\n" >> $installPath/lib/mini_magick/configuration.rb
    '';
  };

  mini_racer = attrs: {
    buildFlags = [
      "--with-v8-dir=\"${nodejs.libv8}\""
    ];
    dontBuild = false;
    postPatch = ''
      substituteInPlace ext/mini_racer_extension/extconf.rb \
        --replace Libv8.configure_makefile '$CPPFLAGS += " -x c++"; Libv8.configure_makefile'
    '';
  };

  do_sqlite3 = attrs: {
    buildInputs = [ sqlite ];
  };

  eventmachine = attrs: {
    dontBuild = false;
    buildInputs = [ openssl ];
    postPatch = ''
      substituteInPlace ext/em.cpp \
        --replace 'if (bind (' 'if (::bind ('
    '';
  };

  exif = attrs: {
    buildFlags = [ "--with-exif-dir=${libexif}" ];
    buildInputs = [ libexif ];
  };

  ffi = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libffi ];
  };

  fiddle = attrs: {
    buildInputs = [ libffi ];
  };

  gdk_pixbuf2 = attrs: {
    nativeBuildInputs = [ pkg-config bundler rake ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    propagatedBuildInputs = [ gobject-introspection wrapGAppsHook3 gdk-pixbuf ];
  };

  gdk3 = attrs: {
    nativeBuildInputs = [ pkg-config bundler rake ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    propagatedBuildInputs = [ gobject-introspection wrapGAppsHook3 gdk-pixbuf cairo ];
  };

  gpgme = attrs: {
    buildInputs = [ gpgme ];
    nativeBuildInputs = [ pkg-config ];
    buildFlags = [ "--use-system-libraries" ];
  };

  gio2 = attrs: {
    nativeBuildInputs = [ pkg-config gobject-introspection ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    buildInputs = [ glib libsysprof-capture pcre2 ] ++ lib.optionals stdenv.hostPlatform.isLinux [ util-linux libselinux libsepol ];
  };

  gitlab-markup = attrs: { meta.priority = 1; };

  gitlab-pg_query = attrs: lib.optionalAttrs (attrs.version == "1.3.1") {
    dontBuild = false;
    postPatch = ''
      sed -i "s;'https://codeload.github.com.*';'${fetchurl {
        url = "https://codeload.github.com/lfittl/libpg_query/tar.gz/10-1.0.3";
        sha256 = "0jfij8apzxsdabl70j42xgd5f3ka1gdcrk764nccp66164gpcchk";
      }}';" ext/pg_query/extconf.rb
    '';
  };

  parser = attrs: {
    meta.mainProgram = "ruby-parse";
  };

  pg_query = attrs: lib.optionalAttrs (attrs.version == "2.0.2") {
    dontBuild = false;
    postPatch = ''
      sed -i "s;'https://codeload.github.com.*';'${fetchurl {
        url = "https://codeload.github.com/lfittl/libpg_query/tar.gz/13-2.0.2";
        sha256 = "0ms2s6hmy8qyzv4g1hj4i2p5fws1v8lrj73b2knwbp2ipd45yj7y";
      }}';" ext/pg_query/extconf.rb
    '';
  } // lib.optionalAttrs (attrs.version == "1.3.0") {
    # Needed for gitlab
    dontBuild = false;
    postPatch = ''
      sed -i "s;'https://codeload.github.com.*';'${fetchurl {
        url = "https://codeload.github.com/lfittl/libpg_query/tar.gz/10-1.0.4";
        sha256 = "0f0kshhai0pnkqj0w4kgz3fssnvwidllc31n1fysxjjzdqlr1k48";
      }}';" ext/pg_query/extconf.rb
    '';
  };

  prettier = attrs: {
    meta.mainProgram = "rbprettier";
  };

  prometheus-client-mmap = attrs: {
    dontBuild = false;
    postPatch = let
      getconf = if stdenv.hostPlatform.isGnu then stdenv.cc.libc else getconf;
    in ''
      substituteInPlace lib/prometheus/client/page_size.rb --replace "getconf" "${lib.getBin getconf}/bin/getconf"
    '';
  } // lib.optionalAttrs (lib.versionAtLeast attrs.version "1.0") {
    cargoDeps = rustPlatform.fetchCargoVendor {
      src = stdenv.mkDerivation {
        inherit (buildRubyGem { inherit (attrs) gemName version source; })
          name
          src
          unpackPhase
          nativeBuildInputs
        ;
        dontBuilt = true;
        installPhase = ''
          cp -R ext/fast_mmaped_file_rs $out
          cp Cargo.lock $out
        '';
      };
      hash = "sha256-KVbmDAa9EFwTUTHPF/8ZzycbieMhAuiidiz5rqGIKOo=";
    };

    nativeBuildInputs = [
      cargo
      rustc
      rustPlatform.cargoSetupHook
      rustPlatform.bindgenHook
    ];

    disallowedReferences = [
      rustc.unwrapped
    ];

    preInstall = ''
      export CARGO_HOME="$PWD/../.cargo/"
    '';

    postInstall = ''
      find $out -type f -name .rustc_info.json -delete
    '';
  };

  glib2 = attrs: {
    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    buildInputs = [ glib libsysprof-capture pcre2 ];
  };

  gtk3 = attrs: {
    nativeBuildInputs = [
      binutils
      pkg-config
    ] ++ lib.optionals stdenv.hostPlatform.isLinux [
      util-linux
      libselinux
      libsepol
    ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    propagatedBuildInputs = [
      atk
      gdk-pixbuf
      fribidi
      gobject-introspection
      gtk3
      cairo
      harfbuzz
      lerc
      libdatrie
      libsysprof-capture
      libthai
      pcre2
      xorg.libpthreadstubs
      xorg.libXdmcp
      xorg.libXtst
      libxkbcommon
      libepoxy
    ];
    dontStrip = stdenv.hostPlatform.isDarwin;
  };

  gobject-introspection = attrs: {
    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    propagatedBuildInputs = [ gobject-introspection wrapGAppsHook3 glib pcre2 libsysprof-capture ];
  };

  gollum = attrs: {
    dontBuild = false;
    postPatch = ''
      substituteInPlace bin/gollum \
        --replace "/usr/bin/env -S ruby" "${ruby}/bin/ruby"
    '';
  };

  google-protobuf = attrs:
    lib.optionalAttrs (lib.versionAtLeast attrs.version "3.25.0") {
    # Fails on 3.25.0 with:
    #   convert.c:312:32: error: format string is not a string literal (potentially insecure) [-Werror,-Wformat-security]
    hardeningDisable = [ "format" ];
  };

  grpc = attrs: {
    nativeBuildInputs = [ pkg-config ]
      ++ lib.optional stdenv.hostPlatform.isDarwin cctools
      ++ lib.optional (lib.versionAtLeast attrs.version "1.53.0" && stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) autoSignDarwinBinariesHook;
    buildInputs = [ openssl ];
    hardeningDisable = [ "format" ];
    env = lib.optionalAttrs (lib.versionOlder attrs.version "1.68.1") {
      NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
    };
    patches = lib.optionals (lib.versionOlder attrs.version "1.65.0") [
      (fetchpatch {
        name = "gcc-14-fixes.patch";
        url = "https://boringssl.googlesource.com/boringssl/+/c70190368c7040c37c1d655f0690bcde2b109a0d%5E%21/?format=TEXT";
        decode = "base64 -d";
        stripLen=1;
        extraPrefix = "third_party/boringssl-with-bazel/src/";
        hash = "sha256-1QyQm5s55op268r72dfExNGV+UyV5Ty6boHa9DQq40U=";
       })
    ];
    dontBuild = false;
    postPatch = ''
      substituteInPlace Makefile \
        --replace '-Wno-invalid-source-encoding' ""
    '' + lib.optionalString (lib.versionOlder attrs.version "1.53.0" && stdenv.hostPlatform.isDarwin) ''
      # For < v1.48.0
      substituteInPlace src/ruby/ext/grpc/extconf.rb \
        --replace "ENV['AR'] = 'libtool -o' if RUBY_PLATFORM =~ /darwin/" ""
      # For >= v1.48.0
      substituteInPlace src/ruby/ext/grpc/extconf.rb \
        --replace 'apple_toolchain = ' 'apple_toolchain = false && '
    '';
  };

  hitimes = attrs: {
    buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ CoreServices ];
  };

  hpricot = attrs: {
    dontBuild = false;
    patches = [
      # Fix incompatible function pointer conversion errors with clang 16
      ./hpricot-fix-incompatible-function-pointer-conversion.patch
    ];
  };

  iconv = attrs: {
    dontBuild = false;
    buildFlags = lib.optionals stdenv.hostPlatform.isDarwin [
      "--with-iconv-dir=${lib.getLib libiconv}"
      "--with-iconv-include=${lib.getDev libiconv}/include"
    ];
    patches = [
      # Fix incompatible function pointer conversion errors with clang 16
      ./iconv-fix-incompatible-function-pointer-conversions.patch
    ];
  };

  idn-ruby = attrs: {
    buildInputs = [ libidn ];
  };

  # disable bundle install as it can't install anything in addition to what is
  # specified in pkgs/applications/misc/jekyll/Gemfile anyway. Also do chmod_R
  # to compensate for read-only files in site_template in nix store.
  jekyll = attrs: {
    postInstall = ''
      installPath=$(cat $out/nix-support/gem-meta/install-path)
      sed -i $installPath/lib/jekyll/commands/new.rb \
          -e 's@Exec.run("bundle", "install"@Exec.run("true"@' \
          -e 's@FileUtils.cp_r site_template + "/.", path@FileUtils.cp_r site_template + "/.", path; FileUtils.chmod_R "u+w", path@'
    '';
  };

  execjs = attrs: {
    propagatedBuildInputs = [ nodejs.libv8 ];
  };

  libxml-ruby = attrs: {
    buildFlags = [
      "--with-xml2-lib=${libxml2.out}/lib"
      "--with-xml2-include=${libxml2.dev}/include/libxml2"
    ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "--with-iconv-dir=${lib.getLib libiconv}"
      "--with-opt-include=${lib.getDev libiconv}/include"
    ];
  };

  mathematical = attrs: {
    nativeBuildInputs = [
      ruby
      cmake
      bison
      flex
      pkg-config
      python3
      patchelf
    ];

    buildInputs = [
      cairo
      fribidi
      gdk-pixbuf
      glib
      libxml2
      pango
    ];

    strictDeps = true;

    # The ruby build script takes care of this
    dontUseCmakeConfigure = true;

    postInstall = ''
      # Reduce output size by a lot, and remove some unnecessary references.
      # The ext directory should only be required at build time, so
      # can be deleted now.
      rm -r $out/${ruby.gemPath}/gems/mathematical-${attrs.version}/ext \
            $out/${ruby.gemPath}/extensions/*/*/mathematical-${attrs.version}/gem_make.out
    '';

    # For some reason 'mathematical.so' is missing cairo, glib, and
    # lasem in its RPATH, add them explicitly here
    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      soPath="$out/${ruby.gemPath}/gems/mathematical-${attrs.version}/lib/mathematical/mathematical.so"
      rpath="$(patchelf --print-rpath "$soPath")"
      patchelf --set-rpath "${lib.makeLibraryPath [ lasem glib cairo ]}:$rpath" "$soPath"
      patchelf --replace-needed liblasem.so liblasem-0.4.so "$soPath"
    ''  + lib.optionalString stdenv.hostPlatform.isDarwin ''
      soPath="$out/${ruby.gemPath}/gems/mathematical-${attrs.version}/lib/mathematical/mathematical.bundle"
      install_name_tool -add_rpath "${lib.makeLibraryPath [ lasem glib cairo ]}/lib" "$soPath"
      install_name_tool -change @rpath/liblasem.dylib "${lib.getLib lasem}/lib/liblasem-0.4.dylib" "$soPath"
    '';
  };

  magic = attrs: {
    buildInputs = [ file ];
    postInstall = ''
      installPath=$(cat $out/nix-support/gem-meta/install-path)
      sed -e 's@ENV\["MAGIC_LIB"\] ||@ENV\["MAGIC_LIB"\] || "${file}/lib/libmagic.so" ||@' -i $installPath/lib/magic/api.rb
    '';
  };

  maxmind_geoip2 = attrs: {
    buildFlags = [ "--with-maxminddb-lib=${libmaxminddb}/lib" "--with-maxminddb-include=${libmaxminddb}/include" ];
  };

  metasploit-framework = attrs: {
    preInstall = ''
      export HOME=$TMPDIR
    '';
  };

  mysql = attrs: {
    buildInputs = [ libmysqlclient zlib openssl ];
  };

  mysql2 = attrs: {
    buildInputs = [ libmysqlclient zlib openssl ];
  };

  ncursesw = attrs: {
    buildInputs = [ ncurses ];
    buildFlags = [
      "--with-cflags=-I${ncurses.dev}/include"
      "--with-ldflags=-L${ncurses.out}/lib"
    ];
  };

  nokogiri = attrs: ({
    buildFlags = [
      "--use-system-libraries"
      "--with-zlib-lib=${zlib.out}/lib"
      "--with-zlib-include=${zlib.dev}/include"
      "--with-xml2-lib=${libxml2.out}/lib"
      "--with-xml2-include=${libxml2.dev}/include/libxml2"
      "--with-xslt-lib=${libxslt.out}/lib"
      "--with-xslt-include=${libxslt.dev}/include"
      "--with-exslt-lib=${libxslt.out}/lib"
      "--with-exslt-include=${libxslt.dev}/include"
    ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "--with-iconv-dir=${libiconv}"
      "--with-opt-include=${libiconv}/include"
    ];
  } // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    buildInputs = [ libxml2 ];

    # libxml 2.12 upgrade requires these fixes
    # https://github.com/sparklemotion/nokogiri/pull/3032
    # which don't trivially apply to older versions
    meta.broken = (lib.versionOlder attrs.version "1.16.0") && (lib.versionAtLeast libxml2.version "2.12");
  });

  openssl = attrs: {
    # https://github.com/ruby/openssl/issues/369
    buildInputs = [ (if (lib.versionAtLeast attrs.version "3.0.0") then openssl else openssl_1_1) ];
  };

  opus-ruby = attrs: {
    dontBuild = false;
    postPatch = ''
      substituteInPlace lib/opus-ruby.rb \
        --replace "ffi_lib 'opus'" \
                  "ffi_lib '${libopus}/lib/libopus${stdenv.hostPlatform.extensions.sharedLibrary}'"
    '';
  };

  ovirt-engine-sdk = attrs: {
    buildInputs = [ curl libxml2 ];
    dontBuild = false;
    meta.broken = stdenv.hostPlatform.isDarwin; # At least until releasing https://github.com/oVirt/ovirt-engine-sdk-ruby/pull/17
  };

  pango = attrs: {
    nativeBuildInputs = [
      pkg-config
    ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ DarwinTools ];
    buildInputs = [ libdatrie libthai fribidi harfbuzz libsysprof-capture pcre2 xorg.libpthreadstubs xorg.libXdmcp ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [ libselinux libsepol util-linux ];
    propagatedBuildInputs = [ gobject-introspection wrapGAppsHook3 ];
  };

  patron = attrs: {
    buildInputs = [ curl ];
  };

  pcaprub = attrs: {
    buildInputs = [ libpcap ];
  };

  pg = attrs: {
    # Force pkg-config lookup for libpq.
    # See https://github.com/ged/ruby-pg/blob/6629dec6656f7ca27619e4675b45225d9e422112/ext/extconf.rb#L34-L55
    #
    # Note that setting --with-pg-config=${lib.getDev postgresql}/bin/pg_config would add
    # an unnecessary reference to the entire postgresql package.
    buildFlags = [ "--with-pg-config=ignore" ];
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libpq ];
  };

  rszr = attrs: {
    buildInputs = [
      imlib2
      imlib2.dev
    ];
    buildFlags = [ "--without-imlib2-config" ];
  };

  psych = attrs: {
    buildInputs = [ libyaml ];
  };

  puma = attrs: {
    buildInputs = [ openssl ];
  };

  "pygments.rb" = attrs: {
    buildInputs = [ python3 ];
  };

  rack = attrs: {
    meta.mainProgram = "rackup";
  };

  railties = attrs: {
    meta.mainProgram = "rails";
  };

  rainbow = attrs: {
    buildInputs = [ rainbow_rake ];
  };

  rbczmq = { ... }: {
    buildInputs = [ zeromq czmq ];
    buildFlags = [ "--with-system-libs" ];
  };

  rbnacl = spec:
    if lib.versionOlder spec.version "6.0.0" then {
      postInstall = ''
        sed -i $(cat $out/nix-support/gem-meta/install-path)/lib/rbnacl.rb -e "2a \
        RBNACL_LIBSODIUM_GEM_LIB_PATH = '${libsodium.out}/lib/libsodium${stdenv.hostPlatform.extensions.sharedLibrary}'
        "
      '';
    } else {
      dontBuild = false;
      postPatch = ''
        substituteInPlace lib/rbnacl/sodium.rb \
          --replace 'ffi_lib ["sodium"' \
                    'ffi_lib ["${libsodium}/lib/libsodium${stdenv.hostPlatform.extensions.sharedLibrary}"'
      '';
    };

  re2 = attrs: {
    buildInputs = [ re2 ];
    buildFlags = [
      "--enable-system-libraries"
    ];
  };

  rest-client = attrs: {
    meta.mainProgram = "restclient";
  };

  rmagick = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ imagemagick which ];
  };

  rouge = attrs: {
    meta.mainProgram = "rougify";
  };

  rpam2 = attrs: {
    buildInputs = [ linux-pam ];
  };

  rspec-core = attrs: {
    meta.mainProgram = "rspec";
  };

  ruby-libvirt = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libvirt ];
    buildFlags = [
      "--with-libvirt-include=${libvirt}/include"
      "--with-libvirt-lib=${libvirt}/lib"
    ];
  };

  ruby-lxc = attrs: {
    buildInputs = [ lxc ];
  };

  ruby-terminfo = attrs: {
    buildInputs = [ ncurses ];
    buildFlags = [
      "--with-cflags=-I${ncurses.dev}/include"
      "--with-ldflags=-L${ncurses.out}/lib"
    ];
    dontBuild = false;
    postPatch = ''
      substituteInPlace extconf.rb --replace 'rubyio.h' 'ruby/io.h'
      substituteInPlace terminfo.c \
        --replace 'rubyio.h' 'ruby/io.h' \
        --replace 'rb_cData' 'rb_cObject'
    '';
  };

  ruby-vips = attrs: {
    postInstall = ''
      cd "$(cat $out/nix-support/gem-meta/install-path)"

      substituteInPlace lib/vips.rb \
        --replace 'library_name("vips", 42)' '"${lib.getLib vips}/lib/libvips${stdenv.hostPlatform.extensions.sharedLibrary}"' \
        --replace 'library_name("glib-2.0", 0)' '"${glib.out}/lib/libglib-2.0${stdenv.hostPlatform.extensions.sharedLibrary}"' \
        --replace 'library_name("gobject-2.0", 0)' '"${glib.out}/lib/libgobject-2.0${stdenv.hostPlatform.extensions.sharedLibrary}"'
    '';
  };

  rugged = attrs: {
    nativeBuildInputs = [ cmake pkg-config which ] ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;
    buildInputs = [ openssl libssh2 zlib ];
    dontUseCmakeConfigure = true;
  };

  sassc = attrs: {
    nativeBuildInputs = [ rake ];
    dontBuild = false;
    SASS_LIBSASS_PATH = toString libsass;
    postPatch = ''
      substituteInPlace lib/sassc/native.rb \
        --replace 'gem_root = spec.gem_dir' 'gem_root = File.join(__dir__, "../../")'
    '';
  };

  sass-embedded = attrs: {
    # Patch the Rakefile to use our dart-sass and not try to fetch anything.
    dontBuild = false;
    postPatch = ''
      substituteInPlace ext/sass/Rakefile \
        --replace \'dart-sass/sass\' \'${dart-sass}/bin/sass\' \
        --replace ' => %w[dart-sass]' ""
    '';
  };

  scrypt = attrs: lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    dontBuild = false;
    postPatch = ''
      sed -i -e "s/-arch i386//" Rakefile ext/scrypt/Rakefile
    '';
  };

  semian = attrs: {
    buildInputs = [ openssl ];
  };

  sequel_pg = attrs: {
    buildInputs = [ libpq ];
  };

  snappy = attrs: {
    buildInputs = [ args.snappy ];
  };

  sqlite3 = attrs: if lib.versionAtLeast attrs.version "1.5.0"
  then {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ sqlite ];
    buildFlags = [
      "--enable-system-libraries"
    ];
  }
  else {
    buildFlags = [
      "--with-sqlite3-include=${sqlite.dev}/include"
      "--with-sqlite3-lib=${sqlite.out}/lib"
    ];
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=incompatible-pointer-types"
      "-Wno-error=int-conversion"
    ];
  };

  rb-readline = attrs: {
    dontBuild = false;
    postPatch = ''
      substituteInPlace lib/rbreadline.rb \
        --replace 'infocmp' '${ncurses}/bin/infocmp'
    '';
  };

  taglib-ruby = attrs: {
    buildInputs = [ taglib_1 ];
  };

  timfel-krb5-auth = attrs: {
    buildInputs = [ libkrb5 ];
  };

  tiny_tds = attrs: {
    nativeBuildInputs = [ pkg-config openssl ];
    buildInputs = [ freetds ];
  };

  treetop = attrs: {
    meta.mainProgram = "tt";
  };

  typhoeus = attrs: {
    buildInputs = [ curl ];
  };

  tzinfo = attrs: lib.optionalAttrs (lib.versionAtLeast attrs.version "1.0") {
    dontBuild = false;
    postPatch =
      let
        path = if lib.versionAtLeast attrs.version "2.0"
               then "lib/tzinfo/data_sources/zoneinfo_data_source.rb"
               else "lib/tzinfo/zoneinfo_data_source.rb";
      in
        ''
          substituteInPlace ${path} \
            --replace "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
        '';
  };

  uuid4r = attrs: {
    buildInputs = [ which libossp_uuid ];
  };

  whois = attrs: {
    meta.mainProgram = "whoisrb";
  };

  xapian-ruby = attrs: {
    # use the system xapian
    dontBuild = false;
    nativeBuildInputs = [ rake pkg-config bundler ];
    buildInputs = [ xapian zlib ];
    postPatch = ''
      cp ${./xapian-Rakefile} Rakefile
    '';
    preInstall = ''
      export XAPIAN_CONFIG=${xapian}/bin/xapian-config
    '';
  };

  zlib = attrs: {
    buildInputs = [ zlib ];
  };

  zookeeper = attrs: {
    buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ cctools ];
  };
}
