{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  setuptools,
  setuptools-scm,
  requests,
  ndjson,
  flask,
  importlib-metadata,
  swh-core,
  swh-model,
  swh-auth,
  swh-web-client,
  beautifulsoup4,
  pytestCheckHook,
  pytest-flask,
  pytest-mock,
  types-beautifulsoup4,
  types-pyyaml,
  types-requests,
}:

buildPythonPackage rec {
  pname = "swh-scanner";
  version = "0.8.3";
  pyproject = true;

  src = fetchFromGitLab {
    domain = "gitlab.softwareheritage.org";
    group = "swh";
    owner = "devel";
    repo = "swh-scanner";
    tag = "v${version}";
    hash = "sha256-baUUuYFapBD7iuDaDP8CSR9f4glVZcS5qBpZddVf7z8=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    requests
    ndjson
    flask
    importlib-metadata
    swh-core
    swh-model
    swh-auth
    swh-web-client
  ];

  pythonImportsCheck = [ "swh.scanner" ];

  nativeCheckInputs = [
    beautifulsoup4
    pytestCheckHook
    pytest-flask
    pytest-mock
    swh-core
    swh-model
    types-beautifulsoup4
    types-pyyaml
    types-requests
  ];

  disabledTests = [
    # AttributeError: 'called_once' is not a valid assertion. Use a spec for the mock if 'called_once' is meant to be an attribute.
    "test_scan_api_url_option_success"
  ];

  disabledTestPaths = [
    # pytestRemoveBytecodePhase fails with: "error (ignored): error: opening directory "/tmp/nix-build-python3.12-swh-scanner-0.8.3.drv-5/build/pytest-of-nixbld/pytest-0/test_randomdir_policy_info_cal0/big-directory/dir/dir/dir/ ......"
    "swh/scanner/tests/test_policy.py"
  ];

  meta = {
    description = "Implementation of the Data model of the Software Heritage project, used to archive source code artifacts";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-model";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
}
