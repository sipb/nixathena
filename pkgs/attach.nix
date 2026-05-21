{
  stdenv,
  pkgs,
  lib,
  fetchFromGitHub,
  openafs,
  autoreconfHook,
  libathdir
}:

stdenv.mkDerivation rec {
  pname = "attach";
  version = "1.16-6f51727";
  src = fetchFromGitHub {
    owner = "mit-athena";
    repo = pname;
    rev = "6f5172794b6d53e07113609596fd100753fc1a20";
    hash = "sha256-R3VPLqT91oEsht3lRBwgFnSO2Bums6adFSDF7ZhJCng=";
  };
  buildInputs = [
    openafs
    autoreconfHook
    libathdir
  ];
  env.NIX_CFLAGS_COMPILE = "-std=gnu89";
  #configureFlags = [
  #  "--sysconfdir=/etc"
  #  "--with-hesiod"
  #  "--with-krb5"
  #];
  #installFlags = [ "sysconfdir=$(out)/etc" ];

  meta = {
    description = "Attach an AFS locker";
    homepage = "https://github.com/mit-athena/attach";
  };
}
