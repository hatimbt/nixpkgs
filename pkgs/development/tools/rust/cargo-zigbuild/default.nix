{ lib, rustPlatform, fetchFromGitHub, makeWrapper, zig }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-zigbuild";
  version = "0.19.7";

  src = fetchFromGitHub {
    owner = "messense";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kuzKW7ol4ZdxIhfAdvAKRb8fgwaU2LTO43dxrpke1Ow=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-WsX1noIRlMRzNqJUxR55CxdTCxJ+DVddVRIbkLtWK1Q=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/cargo-zigbuild \
      --prefix PATH : ${zig}/bin
  '';

  meta = with lib; {
    description = "Tool to compile Cargo projects with zig as the linker";
    mainProgram = "cargo-zigbuild";
    homepage = "https://github.com/messense/cargo-zigbuild";
    changelog = "https://github.com/messense/cargo-zigbuild/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
  };
}
