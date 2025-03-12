{
  lib,
  rustPlatform,
  fetchFromSourcehut,
}:

rustPlatform.buildRustPackage rec {
  pname = "rusty-man";
  version = "0.5.0";

  src = fetchFromSourcehut {
    owner = "~ireas";
    repo = "rusty-man";
    rev = "v${version}";
    sha256 = "sha256-djprzmogT1OEf0/+twdxzx30YaMNzFjXkZd4IDsH8oo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ZIRwp5AJugMDxg3DyFIH5VlD0m4Si2tJdspKE5QEB4M=";

  meta = with lib; {
    description = "Command-line viewer for documentation generated by rustdoc";
    mainProgram = "rusty-man";
    homepage = "https://git.sr.ht/~ireas/rusty-man";
    changelog = "https://git.sr.ht/~ireas/rusty-man/tree/v${version}/item/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
  };
}
