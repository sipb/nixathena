{
  lib,
  runCommand,
  nixosOptionsDoc,
  pkgs,
  hash,
  ...
}:

# Borrowed from https://code.functor.systems/functor.systems/functorOS/src/branch/main/docs/raw.nix

let
   # evaluate our options
  eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit pkgs;
    system = pkgs.stdenv.hostPlatform.system;
    modules = [ ../modules/default.nix ];
  };
  # generate our docs
  optionsDoc = nixosOptionsDoc {
    options = eval.options.nixathena;
  };
in
# create a derivation for capturing the markdown output
runCommand "options-doc.md" { } ''
  tail -n +64 ${optionsDoc.optionsCommonMark} \
    | sed -E 's#\[/nix/store/[a-z0-9]+-source(/[^]]*)\]\(file:///nix/store/[a-z0-9]+-source([^)]*)\)#[\1](https://forgejo.mit.edu/SIPB/nixathena/src/commit/${hash}\2)#g' \
    >> $out
''
