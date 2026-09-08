{
  stdenv,
  lib,
  fetchFromForgejo,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pyhesiodfs";
  version = "1.2";

  src = fetchFromForgejo {
    domain = "forgejo.mit.edu";
    owner = "SIPB";
    repo = "pyhesiodfs";
    rev = "v${version}";
    hash = "sha256-7pwcFDYx+sr6XztLK3FYAgQ95re6MDZA3yqOR7X1e9c=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    fuse
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
