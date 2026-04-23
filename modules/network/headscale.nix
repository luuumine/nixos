{ config, lib, ... }:

let
  cfg = config.lumine.network.headscale;
in
{
  options.lumine.network.headscale = {
    enable = lib.mkEnableOption "headscale control server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "luuumine.com";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "internal headscale port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.port;
      settings = {
        server_url = "https://headscale.${cfg.domain}";
        dns = {
          magic_dns = true;
          base_domain = "vpn.${cfg.domain}";
          nameservers.global = [ "1.1.1.1" ];
        };
      };
    };

    services.caddy.virtualHosts."headscale.${cfg.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
