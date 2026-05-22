{
  stdenv,
  pkgs,
  lib,
  python3Packages,
  fetchFromGitHub,
  installShellFiles,
}:

python3Packages.buildPythonApplication {
  pname = "athrun";
  version = "10.3.2-3c9c5b7";

  src = fetchFromGitHub {
    owner = "mit-athena";
    repo = "athrun";
    rev = "3c9c5b72414454df3c4faad6d92929c5b6e0dc2b";
    hash = "sha256-3kWF6FRaUIqXpKKrWPTqkOyHx2mxl1yP4xWYL3MLqtU=";
  };

  format = "other";

  buildPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    chmod +x athrun attachandrun gathrun
    cp athrun attachandrun gathrun $out/bin
    cp *.1 $out/share/man/man1
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --bash --name athrun.bash bash_completion
    substituteInPlace $out/bin/athrun $out/bin/gathrun \
      --replace-fail "attachandrun" "$out/bin/attachandrun"
  '';

  meta = with lib; {
    description = "TODO";
    homepage = "https://github.com/mit-athena/athrun";
    platforms = platforms.linux;
  };
}
