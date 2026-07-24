# From https://blakesmith.me/2024/03/02/running-nixos-tests-with-flakes.html
{
  self,
  pkgs,
  system,
}:

pkgs.testers.nixosTest {
  name = "meta";
  nodes.machine =
    { config, pkgs, ... }:
    {
      imports = [
        self.nixosModules.default
      ];
      config.nixathena.enable = true;
    };

  testScript = ''
    machine.wait_for_unit("pyhesiodfs.service")
    # network-online.service is too long to wait
    # afsd.service is (seemingly) long enough to have network
    machine.wait_for_unit("afsd.service")
    # Force IPv4 due to MIT IPv6 wonkiness
    [status, out] = machine.execute("ping -4 -c1 example.com")
    print(out)
    machine.succeed('ls /afs/athena.mit.edu/')
    machine.succeed('test -e /mit/sipb/README')
  '';
}
