{ config, lib, ... }:

let
  cfg = config.lumine.network.router;
  types = import ../types { inherit lib; };
in
{
  options.lumine.network.router = {
    enable = lib.mkEnableOption "router";
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
      };

      "11-${cfg.lan.interface.name}" = {
        matchConfig.Name = cfg.lan.interface.name;
        networkConfig.Address = "${cfg.lan.ip}/${toString cfg.lan.prefixLength}";
      };
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        interface = cfg.lan.interface.name;
        bind-interfaces = true;
        dhcp-range = "${cfg.lan.dhcpStart},${cfg.lan.dhcpEnd},24h";
        dhcp-option = [
          "option:router,${cfg.lan.ip}"
          "option:dns-server,${cfg.lan.ip}"
        ];
      };
    };

    networking.nat = {
      enable = true;
      externalInterface = cfg.wan.interface.name;
      internalInterfaces = [ cfg.lan.interface.name ];
    };

    networking.firewall.interfaces."${cfg.lan.interface.name}" = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [
        53
        67
      ];
    };
  };
}
