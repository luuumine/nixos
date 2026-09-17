{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:

let
  cfg = config.lumine.network.mullvad;
  hostname = config.lumine.system.hostname;
in
{
  options.lumine.network.mullvad = {
    enable = lib.mkEnableOption "mullvad wireguard tunnel";

    address = lib.mkOption {
      type = lib.types.str;
      description = "ipv4 address for the mullvad interface";
    };

    exitNode = lib.mkOption {
      description = "mullvad exit node configuration";
      type = lib.types.submodule {
        options = {
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "public key of the mullvad exit node";
          };
          endpoint = lib.mkOption {
            type = lib.types.str;
            description = "endpoint of the mullvad exit node";
          };
          allowedIPs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "0.0.0.0/0"
              "::/0"
            ];
            description = "allowed ip ranges";
          };
          persistentKeepalive = lib.mkOption {
            type = lib.types.int;
            default = 25;
            description = "persistent keepalive interval in seconds";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.checkReversePath = "loose";

    age.secrets.mullvad = {
      file = secretsPath + "/${hostname}/mullvad.age";
      owner = "root";
    };

    networking.wg-quick.interfaces.mullvad = {
      address = [ cfg.address ];
      mtu = 1280;
      privateKeyFile = config.age.secrets.mullvad.path;

      table = "off";

      peers = [ cfg.exitNode ];

      postUp = ''
        ${pkgs.iproute2}/bin/ip route add default dev mullvad table 51820
        ${pkgs.iproute2}/bin/ip route add 10.64.0.1 dev mullvad
        ${pkgs.iproute2}/bin/ip rule add iif tailscale0 table 51820
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o mullvad -j MASQUERADE

        ${pkgs.iproute2}/bin/ip -6 route add default dev mullvad table 51820
        ${pkgs.iproute2}/bin/ip -6 rule add iif tailscale0 table 51820
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o mullvad -j MASQUERADE
      '';

      preDown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o mullvad -j MASQUERADE || true
        ${pkgs.iproute2}/bin/ip rule del iif tailscale0 table 51820 || true
        ${pkgs.iproute2}/bin/ip route del 10.64.0.1 dev mullvad || true
        ${pkgs.iproute2}/bin/ip route del default dev mullvad table 51820 || true

        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -o mullvad -j MASQUERADE || true
        ${pkgs.iproute2}/bin/ip -6 rule del iif tailscale0 table 51820 || true
        ${pkgs.iproute2}/bin/ip -6 route del default dev mullvad table 51820 || true
      '';
    };
  };
}
