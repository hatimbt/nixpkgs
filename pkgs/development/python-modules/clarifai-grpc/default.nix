{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  setuptools,
  googleapis-common-protos,
  grpcio,
  protobuf,
  requests,
}:

buildPythonPackage rec {
  pname = "clarifai-grpc";
  version = "10.11.2";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Clarifai";
    repo = "clarifai-python-grpc";
    tag = version;
    hash = "sha256-Px7VisC2j5pJctzB713cdalEccGbBsSuQBqDarwUTLA=";
  };

  build-system = [ setuptools ];

  dependencies = [
    googleapis-common-protos
    grpcio
    protobuf
    requests
  ];

  pythonRelaxDeps = [
    "grpcio"
  ];

  # almost all tests require network access
  doCheck = false;

  pythonImportsCheck = [ "clarifai_grpc" ];

  meta = {
    description = "Clarifai gRPC API Client";
    homepage = "https://github.com/Clarifai/clarifai-python-grpc";
    changelog = "https://github.com/Clarifai/clarifai-python-grpc/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
