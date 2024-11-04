{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, coreutils
, gawk
, curl
, gnugrep
}:

stdenv.mkDerivation rec {
  pname = "hblock";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "hectorm";
    repo = "hblock";
    rev = "v${version}";
    hash = "sha256-XnBmKOZBHWyjNlv+L24LYns05oGTOJnNNzM0jCwZMuI=";
  };

  buildInputs = [ coreutils curl gnugrep gawk ];
  nativeBuildInputs = [ makeWrapper ];

  installFlags = [
    "prefix=$(out)"
  ];
  postInstall = ''
    wrapProgram "$out/bin/hblock" \
      --prefix PATH : ${lib.makeBinPath [ coreutils curl gnugrep gawk ]}
  '';

  meta = with lib; {
    description = "Improve your security and privacy by blocking ads, tracking and malware domains";
    mainProgram = "hblock";
    homepage = "https://github.com/hectorm/hblock";
    license = licenses.mit;
    maintainers = with maintainers; [ alanpearce ];
    platforms = platforms.unix;
  };
}
