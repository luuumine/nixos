{ lib, ... }:

{
  imports = [
    ./home.nix
    ./mullvad.nix
  ];

  _module.args = {
    vpnSecretsDir = ../../../secrets;
  };

  networking.nameservers = lib.mkForce [ "10.0.0.1" ];

  systemd.services =
    let
      vpnDeps = {
        after = [ "network-online.target" "systemd-resolved.service" ];
        wants = [ "network-online.target" ];
      };
    in {
      wg-quick-home = vpnDeps;
      wg-quick-mullvad = vpnDeps;
    };
}

