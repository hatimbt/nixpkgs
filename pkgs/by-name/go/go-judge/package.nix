{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "go-judge";
  version = "1.8.7";

  src = fetchFromGitHub {
    owner = "criyle";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Qjo9cJwgfULjVsD05H6tlIJHLaNJGjpcLJqQuxoLS8I=";
  };

  vendorHash = "sha256-vkjpD3IbERW/l9ieVncC/9ulrNGyextXx7/f9CTKmqg=";

  tags = [ "nomsgpack" ];

  subPackages = [ "cmd/go-judge" ];

  preBuild = ''
    echo v${version} > ./cmd/go-judge/version/version.txt
  '';

  env.CGO_ENABLED = 0;

  meta = with lib; {
    description = "High performance sandbox service based on container technologies";
    homepage = "https://github.com/criyle/go-judge";
    license = licenses.mit;
    mainProgram = "go-judge";
    maintainers = with maintainers; [ criyle ];
  };
}
