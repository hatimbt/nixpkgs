{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pytestCheckHook,
  numpy,
  libsndfile,
  cffi,
  isPyPy,
  stdenv,
}:

buildPythonPackage rec {
  pname = "soundfile";
  version = "0.13.0";
  pyproject = true;
  # https://github.com/bastibe/python-soundfile/issues/157
  disabled = isPyPy || stdenv.hostPlatform.isi686;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6DOZ2L3n1zsRfDPWoeyFcTGDOPic5y9MPUV+l2h5g1U=";
  };

  postPatch = ''
    substituteInPlace soundfile.py --replace "_find_library('sndfile')" "'${libsndfile.out}/lib/libsndfile${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  build-system = [
    setuptools
    cffi
  ];

  dependencies = [
    numpy
    cffi
  ];

  pythonImportsCheck = [ "soundfile" ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Audio library based on libsndfile, CFFI and NumPy";
    license = lib.licenses.bsd3;
    homepage = "https://github.com/bastibe/python-soundfile";
  };
}
