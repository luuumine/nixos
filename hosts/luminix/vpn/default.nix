{ ... }:

{
  imports = [
    ./home.nix
  ];

  systemd.services =
    let
      vpnDeps = {
        after = [
          "network-online.target"
          "systemd-resolved.service"
        ];
        wants = [ "network-online.target" ];
      };
    in
    {
      wg-quick-home = vpnDeps;
    };
}
