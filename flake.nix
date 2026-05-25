{
  description = "MIT Athena packaging for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "i686-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          f system pkgs
        );
    in
    {
      packages = forAllSystems (
        system: pkgs:
        (import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        })
        // rec {
          # This lets you pick the driver function
          test-infra = {
            metaTest = pkgs.callPackage ./test/meta.nix { inherit self system; };
          };
          # This is what should actually get run
          test = {
            # `nix run .#test.meta` to run this test
            # It requires network (for hesiod and AFS access), so we can't run
            # it in `checks` and need to explicitly choose `.driver` -- the
            # default apparently blocks network.
            meta = test-infra.metaTest.driver;
          };
          docs-rendered = pkgs.callPackage ./docs/rendered.nix {
            docs-raw = pkgs.callPackage ./docs/raw.nix {
              hash = if (self ? rev) then self.rev else "placeholder_hash";
            };
            title = "Nixathena module options for ${if (self ? rev) then self.rev else "placeholder_hash"}";
          };
        }
      );

      overlays.default = import ./pkgs;

      nixosModules.default = import ./modules;

      checks = forAllSystems (
        system: pkgs: {
          # Add things here if we ever get anything that doesn't need network
        }
      );

      formatter = forAllSystems (system: pkgs: pkgs.nixfmt-tree);
    };
}
