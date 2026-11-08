{ config, lib, ... }:

let
  cfg = config.lumine.network.router;
  types = import ../types { inherit lib; };
in
{
  options.lumine.network.router = {
    enable = lib.mkEnableOption "router";
    wanInterface = lib.mkOption {
      type = types.interface;
      example = "wan";
      description = "the interface to use for wan";
    };
    lanInterface = lib.mkOption {
      type = types.interface;
      description = "the interface to use for lan";
    };
    lanAddress = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1/24";
      description = "address to use for the lan network";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkForce false;
    systemd.network.enable = true;

    systemd.network.links = {
      "10-${cfg.wanInterface.name}" = {
        matchConfig.MACAddress = cfg.wanInterface.MACAddress;
        linkConfig.Name = cfg.wanInterface.name;
      };
      "11-${cfg.lanInterface.name}" = {
        matchConfig.MACAddress = cfg.lanInterface.MACAddress;
        linkConfig.Name = cfg.lanInterface.name;
      };
    };

    systemd.network.networks = {
      "10-${cfg.wanInterface.name}" = {
        matchConfig.Name = cfg.wanInterface.name;
        networkConfig.DHCP = "yes";
      };

      "11-${cfg.lanInterface.name}" = {
        matchConfig.Name = cfg.lanInterface.name;
        networkConfig.Address = cfg.lanAddress;
      };
    };
  };
}
