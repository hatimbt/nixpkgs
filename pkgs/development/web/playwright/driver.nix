{
  lib,
  buildNpmPackage,
  stdenv,
  chromium,
  ffmpeg,
  jq,
  nodejs,
  fetchFromGitHub,
  linkFarm,
  callPackage,
  makeFontsConf,
  makeWrapper,
  runCommand,
  writeText,
  cacert,
}:
let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";
  suffix =
    {
      x86_64-linux = "linux";
      aarch64-linux = "linux-arm64";
      x86_64-darwin = "mac";
      aarch64-darwin = "mac-arm64";
    }
    .${system} or throwSystem;

  version = "1.50.1";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "playwright";
    rev = "v${version}";
    hash = "sha256-s4lJRdsA4H+Uf9LjriZ6OimBl5A9Pf4fvhWDw2kOMkg=";
  };

  babel-bundle = buildNpmPackage {
    pname = "babel-bundle";
    inherit version src;
    sourceRoot = "${src.name}/packages/playwright/bundles/babel";
    npmDepsHash = "sha256-HrDTkP2lHl2XKD8aGpmnf6YtSe/w9UePH5W9QfbaoMg=";
    dontNpmBuild = true;
    installPhase = ''
      cp -r . "$out"
    '';
  };
  expect-bundle = buildNpmPackage {
    pname = "expect-bundle";
    inherit version src;
    sourceRoot = "${src.name}/packages/playwright/bundles/expect";
    npmDepsHash = "sha256-KwxNqPefvPPHG4vbco2O4G8WlA7l33toJdfNWHMTDOQ=";
    dontNpmBuild = true;
    installPhase = ''
      cp -r . "$out"
    '';
  };
  utils-bundle = buildNpmPackage {
    pname = "utils-bundle";
    inherit version src;
    sourceRoot = "${src.name}/packages/playwright/bundles/utils";
    npmDepsHash = "sha256-tyk9bv1ethQSm8PKDpLthwsmqJugLIpsUOf9G8TOKRc=";
    dontNpmBuild = true;
    installPhase = ''
      cp -r . "$out"
    '';
  };
  utils-bundle-core = buildNpmPackage {
    pname = "utils-bundle-core";
    inherit version src;
    sourceRoot = "${src.name}/packages/playwright-core/bundles/utils";
    npmDepsHash = "sha256-TarWFVp5JFCKZIvBUTohzzsFaLZHV79lN5+G9+rCP8Y=";
    dontNpmBuild = true;
    installPhase = ''
      cp -r . "$out"
    '';
  };
  zip-bundle = buildNpmPackage {
    pname = "zip-bundle";
    inherit version src;
    sourceRoot = "${src.name}/packages/playwright-core/bundles/zip";
    npmDepsHash = "sha256-62Apz8uX6d4HKDqQxR6w5Vs31tl63McWGPwT6s2YsBE=";
    dontNpmBuild = true;
    installPhase = ''
      cp -r . "$out"
    '';
  };

  playwright = buildNpmPackage {
    pname = "playwright";
    inherit version src;

    sourceRoot = "${src.name}"; # update.sh depends on sourceRoot presence
    npmDepsHash = "sha256-RoKw3Ie41/4DsjCeqkMhKFyjDPuvMgxajZYZhRdiTuY=";

    nativeBuildInputs = [ cacert ];

    ELECTRON_SKIP_BINARY_DOWNLOAD = true;

    postPatch = ''
      sed -i '/\/\/ Update test runner./,/^\s*$/{d}' utils/build/build.js
      sed -i '/\/\/ Update bundles./,/^\s*$/{d}' utils/build/build.js
      sed -i '/execSync/d' ./utils/generate_third_party_notice.js
      sed -i '/plugins: /d' ./packages/playwright/bundles/utils/build.js
      sed -i '/plugins: /d' ./packages/playwright-core/bundles/zip/build.js
      chmod +w packages/playwright/bundles/babel
      ln -s ${babel-bundle}/node_modules packages/playwright/bundles/babel/node_modules
      chmod +w packages/playwright/bundles/expect
      ln -s ${expect-bundle}/node_modules packages/playwright/bundles/expect/node_modules
      chmod +w packages/playwright/bundles/utils
      ln -s ${utils-bundle}/node_modules packages/playwright/bundles/utils/node_modules
      chmod +w packages/playwright-core/bundles/utils
      ln -s ${utils-bundle-core}/node_modules packages/playwright-core/bundles/utils/node_modules
      chmod +w packages/playwright-core/bundles/zip
      ln -s ${zip-bundle}/node_modules packages/playwright-core/bundles/zip/node_modules
    '';

    installPhase = ''
      runHook preInstall

      shopt -s extglob

      mkdir -p "$out/lib"
      cp -r packages/playwright/node_modules "$out/lib/node_modules"

      mkdir -p "$out/lib/node_modules/playwright"
      cp -r packages/playwright/!(bundles|src|node_modules|.*) "$out/lib/node_modules/playwright"

      mkdir -p "$out/lib/node_modules/playwright-core"
      cp -r packages/playwright-core/!(bundles|src|bin|.*) "$out/lib/node_modules/playwright-core"

      mkdir -p "$out/lib/node_modules/@playwright/test"
      cp -r packages/playwright-test/* "$out/lib/node_modules/@playwright/test"

      runHook postInstall
    '';

    meta = {
      description = "Framework for Web Testing and Automation";
      homepage = "https://playwright.dev";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ kalekseev ];
      inherit (nodejs.meta) platforms;
    };
  };

  playwright-core = stdenv.mkDerivation (finalAttrs: {
    pname = "playwright-core";
    inherit (playwright) version src meta;

    installPhase = ''
      runHook preInstall

      cp -r ${playwright}/lib/node_modules/playwright-core "$out"

      runHook postInstall
    '';

    passthru = {
      browsersJSON = (lib.importJSON ./browsers.json).browsers;
      browsers = browsers { };
      browsers-chromium = browsers {
        withFirefox = false;
        withWebkit = false;
        withChromiumHeadlessShell = false;
      };
    };
  });

  playwright-test = stdenv.mkDerivation (finalAttrs: {
    pname = "playwright-test";
    inherit (playwright) version src;

    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      runHook preInstall

      shopt -s extglob
      mkdir -p $out/bin
      cp -r ${playwright}/* $out

      makeWrapper "${nodejs}/bin/node" "$out/bin/playwright" \
        --add-flags "$out/lib/node_modules/@playwright/test/cli.js" \
        --prefix NODE_PATH : ${placeholder "out"}/lib/node_modules \
        --set-default PLAYWRIGHT_BROWSERS_PATH "${playwright-core.passthru.browsers}"

      runHook postInstall
    '';

    setupHook = writeText "setupHook.sh" ''
      addBrowsersPath () {
        if [[ ! -v PLAYWRIGHT_BROWSERS_PATH ]] ; then
          export PLAYWRIGHT_BROWSERS_PATH="${playwright-core.passthru.browsers}"
        fi
      }

      addEnvHooks "$targetOffset" addBrowsersPath
    '';

    meta = playwright.meta // {
      mainProgram = "playwright";
    };

    passthru.tests.env = runCommand "playwright-core-env-test" {
      buildInputs = [
        nodejs
        playwright-core
        playwright-test
      ];
    } "node ${./test.js}";
  });

  browsers = lib.makeOverridable (
    {
      withChromium ? true,
      withFirefox ? true,
      withWebkit ? true,
      withFfmpeg ? true,
      withChromiumHeadlessShell ? true,
      fontconfig_file ? makeFontsConf {
        fontDirectories = [ ];
      },
    }:
    let
      browsers =
        lib.optionals withChromium [ "chromium" ]
        ++ lib.optionals withChromiumHeadlessShell [ "chromium-headless-shell" ]
        ++ lib.optionals withFirefox [ "firefox" ]
        ++ lib.optionals withWebkit [ "webkit" ]
        ++ lib.optionals withFfmpeg [ "ffmpeg" ];
    in
    linkFarm "playwright-browsers" (
      lib.listToAttrs (
        map (
          name:
          let
            revName = if name == "chromium-headless-shell" then "chromium" else name;
            value = playwright-core.passthru.browsersJSON.${revName};
          in
          lib.nameValuePair
            # TODO check platform for revisionOverrides
            "${lib.replaceStrings [ "-" ] [ "_" ] name}-${value.revision}"
            (
              callPackage (./. + "/${name}.nix") (
                {
                  inherit suffix system throwSystem;
                  inherit (value) revision;
                }
                // lib.optionalAttrs (name == "chromium") {
                  inherit fontconfig_file;
                }
              )
            )
        ) browsers
      )
    )
  );
in
{
  playwright-core = playwright-core;
  playwright-test = playwright-test;
}
