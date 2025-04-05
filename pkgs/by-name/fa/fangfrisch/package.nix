{
  lib,
  python3,
  fetchFromGitHub,
}:
let
  version = "1.9.2";
in
python3.pkgs.buildPythonApplication {
  pname = "fangfrisch";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rseichter";
    repo = "fangfrisch";
    tag = version;
    hash = "sha256-8upIh9Z+ismvuKcuEe+gJ4W9NLw/Wq15zjFpy8X9yVo=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    sqlalchemy
  ];

  pythonImportsCheck = [ "fangfrisch" ];

  meta = with lib; {
    description = "Update and verify unofficial Clam Anti-Virus signatures";
    homepage = "https://github.com/rseichter/fangfrisch";
    changelog = "https://github.com/rseichter/fangfrisch/blob/${version}/CHANGELOG.rst";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ happysalada ];
    mainProgram = "fangfrisch";
  };
}
