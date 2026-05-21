{
  stdenv,
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  python-afs,
  python-hesiod,
}:

let
  fs = lib.fileset;
in
buildPythonPackage {
  pname = "locker-support";
  version = "10.4.7";

  src = fetchFromGitHub {
    owner = "mit-athena";
    repo = "locker-support";
    rev = "10.4.7";
    hash = "sha256-s/L6LbBcRdno1EFbTDeQg5CMV2uJLn7xaOQgpiFLOfQ=";
  };

  pyproject = true;
  build-system = [
    setuptools
  ];

  patches = [
    ./python3.patch
  ];

  dependencies = [
    python-afs
    python-hesiod
  ];

  buildInputs = [
  ];

  nativeBuildInputs = [
  ];

  pythonImportsCheck = [
    "locker"
    "athdir"
  ];

  meta = {
    description = ''Python modules for Athena's "locker" framework'';
    longDescription = ''
      This package provides the "locker" and "athdir" modules, for use
      with debathena-pyhesiodfs and more
    '';
    homepage = "https://github.com/mit-athena/locker-support";
    license = lib.licenses.bsd3;
  };
}
