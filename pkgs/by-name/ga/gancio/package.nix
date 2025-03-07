{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchYarnDeps,

  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  pkg-config,

  vips,
  sqlite,

  nixosTests,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gancio";
  version = "1.24.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "les";
    repo = "gancio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PczJFh4tODwtocDSY0UHok8tgBmVvSVHDRjLG6Cor5s=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-LXeAyxZSZOm6GxRuJb5rlHTlQpYa1fdKSENVjwLY4tU=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    (nodejs.python.withPackages (ps: [ ps.setuptools ]))
    pkg-config
  ];

  buildInputs = [
    vips
    sqlite
  ];

  # generate .node binaries
  preBuild = ''
    npm rebuild --verbose --nodedir=${nodejs} --sqlite=${lib.getDev sqlite}
  '';

  # the node_modules directory will be regenerated by yarnInstallHook, so we save our .node binaries
  preInstall = ''
    cp node_modules/sharp/build/Release/sharp.node .
    cp node_modules/sqlite3/build/Release/node_sqlite3.node .
  '';

  # and then place them where they belong
  postInstall = ''
    install -Dm755 sharp.node -t $out/lib/node_modules/gancio/node_modules/sharp/build/Release
    install -Dm755 node_sqlite3.node -t $out/lib/node_modules/gancio/node_modules/sqlite3/build/Release
  '';

  passthru = {
    inherit nodejs;
    tests = {
      inherit (nixosTests) gancio;
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Shared agenda for local communities, running on nodejs";
    homepage = "https://gancio.org/";
    changelog = "https://framagit.org/les/gancio/-/raw/master/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gancio";
    maintainers = with lib.maintainers; [ jbgi ];
  };
})
