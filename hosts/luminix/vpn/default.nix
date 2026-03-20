{ ... }:

{
  imports = [
    ./home.nix
    ./mullvad.nix
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
      wg-quick-mullvad = vpnDeps;
    };
}
