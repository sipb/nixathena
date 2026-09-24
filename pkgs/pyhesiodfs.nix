{
  stdenv,
  lib,
  fetchFromForgejo,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhesiodfs";
  version = "2.0";

  src = fetchFromForgejo {
    domain = "forgejo.mit.edu";
    owner = "SIPB";
    repo = "pyhesiodfs";
    rev = "v${version}";
    hash = "sha256-eirRm9NPbw+7jbgijZ9J6pIM4iBZjjGL60E0Jt8+rcg=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    mfusepy
    python-hesiod
    locker-support
  ];

  meta = with lib; {
    description = "Modern fork of https://github.com/mit-athena/pyhesiodfs";
    homepage = "https://forgejo.mit.edu/SIPB/pyhesiodfs";
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
