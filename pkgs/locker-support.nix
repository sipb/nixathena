{
  stdenv,
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  python-afs,
  python-hesiod,
  six,
}:

let
  fs = lib.fileset;
in
buildPythonPackage {
  pname = "locker-support";
  version = "10.4.8";

  # Fork of https://github.com/mit-athena/locker-support with Python 3 support
  src = fetchFromGitHub {
    owner = "macathena";
    repo = "locker-support";
    rev = "3801013b44488dab81bcea2b72634ba9340a1499";
    hash = "sha256-s/L6LbBcRdno1EFbTDeQg5CMV2uJLn7xaOQgpiFLOfQ=";
  };

  pyproject = true;
  build-system = [
    setuptools
  ];

  dependencies = [
    python-afs
    python-hesiod
    six
  ];

  pythonImportsCheck = [
    "locker"
    "athdir"
  ];

  meta = {
    description = ''Python modules for Athena's "locker" framework (Python 3 fork)'';
    longDescription = ''
      This package provides the "locker" and "athdir" modules, for use
      with debathena-pyhesiodfs and more
    '';
    homepage = "https://github.com/macathena/locker-support";
    license = lib.licenses.bsd3;
  };
}
