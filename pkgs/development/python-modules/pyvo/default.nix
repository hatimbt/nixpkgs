{
  lib,
  buildPythonPackage,
  fetchPypi,
  astropy,
  pillow,
  pythonOlder,
  pytestCheckHook,
  pytest-astropy,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyvo";
  version = "1.5.3";
  pyproject = true;

  disabled = pythonOlder "3.8"; # according to setup.cfg

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/ShNDoT1KucV4YVUeUz8BP33nsQF4YlpvbFs6vCxmH4=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    requests
  ];

  nativeCheckInputs = [
    pillow
    pytestCheckHook
    pytest-astropy
    requests-mock
  ];

  disabledTestPaths = [
    # touches network
    "pyvo/dal/tests/test_datalink.py"
  ];

  pythonImportsCheck = [ "pyvo" ];

  meta = with lib; {
    description = "Astropy affiliated package for accessing Virtual Observatory data and services";
    homepage = "https://github.com/astropy/pyvo";
    license = licenses.bsd3;
    maintainers = with maintainers; [ smaret ];
  };
}
