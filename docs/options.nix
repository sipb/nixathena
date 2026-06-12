{
  pkgs,
  nixosOptionsDoc,
  stdenvNoCC,
  ...
}:

# Borrowed from https://code.functor.systems/functor.systems/functorOS/src/branch/main/docs/raw.nix

let
  # Evaluate our options
  eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit pkgs;
    system = pkgs.stdenv.hostPlatform.system;
    modules = [ ../modules/default.nix ];
  };
  # Generate our docs
  optionsDoc = nixosOptionsDoc {
    options = eval.options.nixathena;
  };
in
stdenvNoCC.mkDerivation {
  name = "docs";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    sed -E 's#/nix/store/[a-z0-9]+-source##g' ${optionsDoc.optionsCommonMark} | sed -E 's#file://#..#g' > $out/options.md
  '';
}
