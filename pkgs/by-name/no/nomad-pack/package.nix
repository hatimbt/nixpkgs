{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "nomad-pack";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad-pack";
    rev = "v${version}";
    sha256 = "sha256-QtpTnChLB9OfzLSJXr19geHzxmOeL5DQ0G4fgcqCdbc=";
  };

  vendorHash = "sha256-lygNUHerj9bMJk2+PTUeAJIdTPK9nUYXaByZpzh7uLY=";

  # skip running go tests as they require network access
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/nomad-pack --version
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/hashicorp/nomad-pack";
    changelog = "https://github.com/hashicorp/nomad-pack/blob/main/CHANGELOG.md";
    description = "Nomad Pack is a templating and packaging tool used with HashiCorp Nomad";
    license = licenses.mpl20;
    maintainers = with maintainers; [ techknowlogick ];
  };

}
