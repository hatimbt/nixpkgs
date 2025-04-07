{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "tarssh";
  version = "0.7.0";

  src = fetchFromGitHub {
    tag = "v${version}";
    owner = "Freaky";
    repo = pname;
    sha256 = "sha256-AoKc8VF6rqYIsijIfgvevwu+6+suOO7XQCXXgAPNgLk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-r1WwAL24Ohmf4L7UXUwmecRiMmthjpzoWOVv33bMkDk=";

  meta = with lib; {
    description = "Simple SSH tarpit inspired by endlessh";
    homepage = "https://github.com/Freaky/tarssh";
    license = [ licenses.mit ];
    maintainers = with maintainers; [ sohalt ];
    platforms = platforms.unix;
    mainProgram = "tarssh";
  };
}
