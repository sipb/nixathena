{
  description = "MIT Athena packaging for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (
        pkgs:
        (import ./default.nix { inherit pkgs; })
        // rec {
          # This lets you pick the driver function
          test-infra = {
            metaTest = pkgs.callPackage ./test/meta.nix { inherit self; };
          };
          # This is what should actually get run
          test = {
            # `nix run .#test.meta` to run this test
            # It requires network (for hesiod and AFS access), so we can't run
            # it in `checks` and need to explicitly choose `.driver` -- the
            # default apparently blocks network.
            meta = test-infra.metaTest.driver;
          };
          docs = pkgs.callPackage ./docs/options.nix { };
        }
      );

      nixosModules.default = import ./modules;

      checks = forAllSystems (pkgs: {
        # Add things here if we ever get anything that doesn't need network
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
