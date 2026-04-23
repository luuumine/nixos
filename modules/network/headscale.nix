{ config, lib, ... }:

let
  cfg = config.lumine.network.headscale;
in
{
  options.lumine.network.headscale = {
    enable = lib.mkEnableOption "headscale control server";
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "http://192.168.1.1:8080";
        dns = {
          magic_dns = true;
          base_domain = "vpn.luuumine.com";
          nameservers.global = [ "1.1.1.1" ];
        };
      };
    };
  };
}
