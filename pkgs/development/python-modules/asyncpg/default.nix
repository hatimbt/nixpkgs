{
  lib,
  fetchPypi,
  buildPythonPackage,
  async-timeout,
  uvloop,
  postgresql,
  pythonOlder,
  pytest-xdist,
  pytestCheckHook,
  distro,
}:

buildPythonPackage rec {
  pname = "asyncpg";
  version = "0.30.0";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xVHpkoq2cHYC9EgRgX+CujxEbgGL/h06vsyLpfPqyFE=";
  };

  # sandboxing issues on aarch64-darwin, see https://github.com/NixOS/nixpkgs/issues/198495
  doCheck = postgresql.doInstallCheck;

  # required for compatibility with Python versions older than 3.11
  # see https://github.com/MagicStack/asyncpg/blob/v0.29.0/asyncpg/_asyncio_compat.py#L13
  propagatedBuildInputs = lib.optionals (pythonOlder "3.11") [ async-timeout ];

  nativeCheckInputs = [
    uvloop
    postgresql
    pytest-xdist
    pytestCheckHook
    distro
  ];

  preCheck = ''
    rm -rf asyncpg/
  '';

  # https://github.com/MagicStack/asyncpg/issues/1236
  disabledTests = [ "test_connect_params" ];

  pythonImportsCheck = [ "asyncpg" ];

  meta = with lib; {
    description = "Asyncio PosgtreSQL driver";
    homepage = "https://github.com/MagicStack/asyncpg";
    changelog = "https://github.com/MagicStack/asyncpg/releases/tag/v${version}";
    longDescription = ''
      Asyncpg is a database interface library designed specifically for
      PostgreSQL and Python/asyncio. asyncpg is an efficient, clean
      implementation of PostgreSQL server binary protocol for use with Python's
      asyncio framework.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ eadwu ];
  };
}
