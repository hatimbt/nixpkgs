{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build system
  poetry-core,

  # dependencies
  langchain-core,
  msgpack,

  # testing
  dataclasses-json,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,

  # passthru
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "langgraph-checkpoint";
  version = "2.0.16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "checkpoint==${version}";
    hash = "sha256-HieCzNM+z7d0UGL8QOyjNP5P2IbLf0x0xhaUCWM/c0k=";
  };

  sourceRoot = "${src.name}/libs/checkpoint";

  build-system = [ poetry-core ];

  dependencies = [ langchain-core ];

  propagatedBuildInputs = [ msgpack ];

  pythonRelaxDeps = [ "msgpack" ]; # Can drop after msgpack 1.0.10 lands in nixpkgs

  pythonImportsCheck = [ "langgraph.checkpoint" ];

  nativeCheckInputs = [
    dataclasses-json
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # AssertionError
    "test_serde_jsonplus"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "checkpoint==(\\d+\\.\\d+\\.\\d+)"
    ];
  };

  meta = {
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/checkpoint==${version}";
    description = "Library with base interfaces for LangGraph checkpoint savers";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/checkpoint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      drupol
      sarahec
    ];
  };
}
