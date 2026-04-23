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
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.checkReversePath = "loose";

    age.secrets.mullvad = {
      file = secretsPath + "/${hostname}/mullvad.age";
      owner = "root";
    };

    networking.wg-quick.interfaces.mullvad = {
      address = [
        "10.71.142.112/32"
        "fc00:bbbb:bbbb:bb01::8:8e6f/128"
      ];
      mtu = 1280;
      privateKeyFile = config.age.secrets.mullvad.path;

      table = "off";

      peers = [
        {
          # Amsterdam (nl-ams-wg-001)
          publicKey = "UrQiI9ISdPPzd4ARw1NHOPKKvKvxUhjwRjaI0JpJFgM=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "193.32.249.66:51820";
          persistentKeepalive = 25;
        }
      ];

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
