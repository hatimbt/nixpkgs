{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "nuclei";
  version = "3.4.2";

  src = fetchFromGitHub {
    owner = "projectdiscovery";
    repo = "nuclei";
    tag = "v${version}";
    hash = "sha256-p3coR11+1xFQF3flIxfEP6HqQOD7+gHuT0ysOSKQyzc=";
  };

  vendorHash = "sha256-cT8ZDp1GSdlgMr0i23i2WAVRmSbhwZZa/RKNPezr9l0=";

  proxyVendor = true; # hash mismatch between Linux and Darwin

  subPackages = [ "cmd/nuclei/" ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-w"
    "-s"
  ];

  # Test files are not part of the release tarball
  doCheck = false;

  doInstallCheck = true;

  versionCheckProgramArg = "-version";

  meta = with lib; {
    description = "Tool for configurable targeted scanning";
    longDescription = ''
      Nuclei is used to send requests across targets based on a template
      leading to zero false positives and providing effective scanning
      for known paths. Main use cases for nuclei are during initial
      reconnaissance phase to quickly check for low hanging fruits or
      CVEs across targets that are known and easily detectable.
    '';
    homepage = "https://github.com/projectdiscovery/nuclei";
    changelog = "https://github.com/projectdiscovery/nuclei/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [
      fab
      Misaka13514
    ];
    mainProgram = "nuclei";
  };
}
