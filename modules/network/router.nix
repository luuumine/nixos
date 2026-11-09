{ config, lib, ... }:

let
  cfg = config.lumine.network.router;
  types = import ../types { inherit lib; };
in
{
  options.lumine.network.router = {
    enable = lib.mkEnableOption "router";
    servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      description = "the upstream dns servers to use";
    };
    wan = {
      interface = lib.mkOption {
        type = types.interface;
        example = "wan";
        description = "the interface to use for wan";
      };
    };
    lan = {
      interface = lib.mkOption {
        type = types.interface;
        description = "the internal interface serving the lan";
      };
      ip = lib.mkOption {
        type = lib.types.str;
        example = "192.168.1.1";
        description = "the router's raw IPv4 on the lan";
      };
      prefixLength = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "the subnet prefix length";
      };
      dhcpStart = lib.mkOption {
        type = lib.types.str;
        example = "192.168.1.100";
        description = "the first IP address in the dhcp pool";
      };
      dhcpEnd = lib.mkOption {
        type = lib.types.str;
        example = "192.168.1.200";
        description = "the last IP address in the dhcp pool";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkForce false;
    systemd.network.enable = true;
    networking.useNetworkd = true;
    networking.useDHCP = false;

    services.resolved.enable = false;

    networking.firewall."${cfg.lan.interface.name}" = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [
        53
        67
      ];
    };

    systemd.network.links = {
      "10-${cfg.wan.interface.name}" = {
        matchConfig.MACAddress = cfg.wan.interface.MACAddress;
        linkConfig.Name = cfg.wan.interface.name;
      };
      "11-${cfg.lan.interface.name}" = {
        matchConfig.MACAddress = cfg.lan.interface.MACAddress;
        linkConfig.Name = cfg.lan.interface.name;
      };
    };

    systemd.network.networks = {
      "10-${cfg.wan.interface.name}" = {
        matchConfig.Name = cfg.wan.interface.name;
        networkConfig.DHCP = "yes";
        dhcpV4Config.ClientIdentifier = "mac";
      };

      "11-${cfg.lan.interface.name}" = {
        matchConfig.Name = cfg.lan.interface.name;
        networkConfig = {
          Address = "${cfg.lan.ip}/${toString cfg.lan.prefixLength}";
          DHCP = "no";
        };
        linkConfig.RequiredForOnline = "no";
      };
    };

    networking.nat = {
      enable = true;
      externalInterface = cfg.wan.interface.name;
      internalInterfaces = [ cfg.lan.interface.name ];
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        server = cfg.servers;
        domain-needed = true;
        no-hosts = true;

        interface = cfg.lan.interface.name;
        dhcp-range = [ "${cfg.lan.dhcpStart},${cfg.lan.dhcpEnd},24h" ];
        dhcp-option = [
          "option:router,${cfg.lan.ip}"
          "option:dns-server,${cfg.lan.ip}"
        ];
        log-dhcp = true;
      };
    };
  };
}
