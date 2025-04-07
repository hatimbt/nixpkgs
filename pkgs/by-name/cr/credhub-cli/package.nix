{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "credhub-cli";
  version = "2.9.44";

  src = fetchFromGitHub {
    owner = "cloudfoundry-incubator";
    repo = "credhub-cli";
    tag = version;
    sha256 = "sha256-5963iZ7fDNs+J96+GSoGcjKLCqu8u3obAWE9+9oEBGU=";
  };

  # these tests require network access that we're not going to give them
  postPatch = ''
    rm commands/api_test.go
    rm commands/socks5_test.go
  '';
  __darwinAllowLocalNetworking = true;

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X code.cloudfoundry.org/credhub-cli/version.Version=${version}"
  ];

  postInstall = ''
    ln -s $out/bin/credhub-cli $out/bin/credhub
  '';

  preCheck = ''
    export HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "Provides a command line interface to interact with CredHub servers";
    homepage = "https://github.com/cloudfoundry-incubator/credhub-cli";
    maintainers = with maintainers; [ ris ];
    license = licenses.asl20;
  };
}
