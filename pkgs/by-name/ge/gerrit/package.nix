{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  nixosTests,
}:

stdenv.mkDerivation rec {
  pname = "gerrit";
  version = "3.11.2";

  src = fetchurl {
    url = "https://gerrit-releases.storage.googleapis.com/gerrit-${version}.war";
    hash = "sha256-F3kWGIA7RvbPMAs9U9tAmraHpxbkW/TQ6R9XXVBaLXs=";
  };

  buildCommand = ''
    mkdir -p "$out"/webapps/
    ln -s ${src} "$out"/webapps/gerrit-${version}.war
  '';

  passthru = {
    updateScript = gitUpdater {
      url = "https://gerrit.googlesource.com/gerrit";
      rev-prefix = "v";
      allowedVersions = "^[0-9\\.]+$";
    };
    # A list of plugins that are part of the gerrit.war file.
    # Use `java -jar gerrit.war ls | grep plugins/` to generate that list.
    plugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "plugin-manager"
      "replication"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];
    tests = {
      inherit (nixosTests) gerrit;
    };
  };

  meta = with lib; {
    homepage = "https://www.gerritcodereview.com/index.md";
    license = licenses.asl20;
    description = "Web based code review and repository management for the git version control system";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    maintainers = with maintainers; [
      flokli
      zimbatm
      felixsinger
    ];
    platforms = platforms.unix;
  };
}
