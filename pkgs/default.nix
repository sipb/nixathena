# https://nix.dev/tutorials/packaging-existing-software#building-with-nix-build
# default.nix
final: prev:
let
  inherit (final) callPackage;
in
{
  debathena-aclocal = callPackage ./aclocal.nix { };
  discuss = callPackage ./discuss.nix { };
  hesiod = callPackage ./hesiod.nix { };
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev:
      let
        inherit (python-final) callPackage;
      in
      {
        python-discuss = callPackage ./python-discuss.nix { };
        python-afs = callPackage ./python-afs.nix { };
        python-hesiod = callPackage ./python-hesiod.nix { };
        locker-support = callPackage ./locker-support.nix { };
      }
    )
  ];
  pyhesiodfs = callPackage ./pyhesiodfs.nix { };
  remctl = callPackage ./remctl.nix { };
  moira = callPackage ./moira.nix { };
  pam-afs-session = callPackage ./pam-afs-session.nix { };
  lightdm-debathena-greeter = callPackage ./lightdm-debathena-greeter.nix { };
  libkrb5-e2fs = callPackage ./libkrb5-e2fs.nix { };
  zephyr = callPackage ./zephyr.nix { };
  barnowl = callPackage ./barnowl.nix { };
  athrun = callPackage ./athrun.nix { };
}

# Running `nix-build default.nix` will run the build and spit out a path
# Running `nix-build default.nix -A docker` will make `result` point to the
# Docker image. Similarly for `-A formationbot`. Without `-A`, we get
# `result` and `result-2`.
