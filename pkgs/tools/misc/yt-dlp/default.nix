{ lib
, buildPythonPackage
, fetchPypi
, brotli
, hatchling
, certifi
, ffmpeg
, rtmpdump
, atomicparsley
, pycryptodomex
, websockets
, mutagen
, pythonRelaxDepsHook
, requests
, secretstorage
, urllib3
, atomicparsleySupport ? true
, ffmpegSupport ? true
, rtmpSupport ? true
, withAlias ? false # Provides bin/youtube-dl for backcompat
, update-python-libraries
}:

buildPythonPackage rec {
  pname = "yt-dlp";
  # The websites yt-dlp deals with are a very moving target. That means that
  # downloads break constantly. Because of that, updates should always be backported
  # to the latest stable release.
  version = "2024.11.4";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "yt_dlp";
    hash = "sha256-7SBMG2G8Vj4TREd2bRqzQxc1QHmeE+u5U+iHzn3PaGU=";
  };

  build-system = [
    hatchling
    pythonRelaxDepsHook
  ];

  dependencies = [
    brotli
    certifi
    mutagen
    pycryptodomex
    requests
    secretstorage # "optional", as in not in requirements.txt, needed for `--cookies-from-browser`
    urllib3
    websockets
  ];

  pythonRelaxDeps = [
    "requests"
    "websockets"
  ];

  # Ensure these utilities are available in $PATH:
  # - ffmpeg: post-processing & transcoding support
  # - rtmpdump: download files over RTMP
  # - atomicparsley: embedding thumbnails
  makeWrapperArgs =
    let
      packagesToBinPath =
        [ ]
        ++ lib.optional atomicparsleySupport atomicparsley
        ++ lib.optional ffmpegSupport ffmpeg
        ++ lib.optional rtmpSupport rtmpdump;
    in
    lib.optionals (packagesToBinPath != [ ]) [
      ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"''
    ];

  setupPyBuildFlags = [
    "build_lazy_extractors"
  ];

  # Requires network
  doCheck = false;

  postInstall = lib.optionalString withAlias ''
    ln -s "$out/bin/yt-dlp" "$out/bin/youtube-dl"
  '';

  passthru.updateScript = [
    update-python-libraries
    (toString ./.)
  ];

  meta = with lib; {
    homepage = "https://github.com/yt-dlp/yt-dlp/";
    description = "Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)";
    longDescription = ''
      yt-dlp is a youtube-dl fork based on the now inactive youtube-dlc.

      youtube-dl is a small, Python-based command-line program
      to download videos from YouTube.com and a few more sites.
      youtube-dl is released to the public domain, which means
      you can modify it, redistribute it or use it however you like.
    '';
    changelog = "https://github.com/yt-dlp/yt-dlp/blob/HEAD/Changelog.md";
    license = licenses.unlicense;
    maintainers = with maintainers; [
      mkg20001
      SuperSandro2000
    ];
    mainProgram = "yt-dlp";
  };
}
