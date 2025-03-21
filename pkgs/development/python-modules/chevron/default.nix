{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
}:

buildPythonPackage {
  pname = "chevron";
  version = "0.14.0-unstable-2021-03-21";
  format = "setuptools";

  # No tests available in the PyPI tarball
  src = fetchFromGitHub {
    owner = "noahmorrison";
    repo = "chevron";
    rev = "5e1c12827b7fc3db30cb3b24cae9a7ee3092822b";
    sha256 = "sha256-44cxkliJJ+IozmhS4ekbb+pCa7tcUuX9tRNYTK0mC+w=";
  };

  checkPhase = ''
    ${python.interpreter} test_spec.py
  '';

  meta = with lib; {
    homepage = "https://github.com/noahmorrison/chevron";
    description = "Python implementation of the mustache templating language";
    mainProgram = "chevron";
    license = licenses.mit;
    maintainers = with maintainers; [ dhkl ];
  };
}
