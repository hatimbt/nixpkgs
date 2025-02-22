{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  karmor,
}:

buildGoModule rec {
  pname = "karmor";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "kubearmor";
    repo = "kubearmor-client";
    rev = "v${version}";
    hash = "sha256-XZ/FGZK6whh32sO7TuBooPRB1u2I0p5aDePcZ5AaY/8=";
  };

  vendorHash = "sha256-HH3U1reZXG9w7uwnXbY33hsKlPCxbVb2yvw4KmBfOa0=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.BuildDate=1970-01-01"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.GitSummary=${version}"
  ];

  # integration tests require network access
  doCheck = false;

  postInstall = ''
    mv $out/bin/{kubearmor-client,karmor}
    installShellCompletion --cmd karmor \
      --bash <($out/bin/karmor completion bash) \
      --fish <($out/bin/karmor completion fish) \
      --zsh  <($out/bin/karmor completion zsh)
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = karmor;
      command = "karmor version || true";
    };
  };

  meta = with lib; {
    description = "Client tool to help manage KubeArmor";
    mainProgram = "karmor";
    homepage = "https://kubearmor.io";
    changelog = "https://github.com/kubearmor/kubearmor-client/releases/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [
      urandom
      kashw2
    ];
  };
}
