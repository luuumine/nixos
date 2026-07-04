{
  config,
  lib,
  secretsPath,
  ...
}:

let
  cfg = config.lumine.services.wealthfolio;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;

  vpnDomain = "vpn.luuumine.com";
in
{
  options.lumine.services.wealthfolio = {
    enable = lib.mkEnableOption "local wealthfolio server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8088;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.wealthfolio-key = {
      file = secretsPath + "/${hostname}/wealthfolio-key.age";
    };

    services.wealthfolio = {
      enable = true;
      port = cfg.port;
      address = "127.0.0.1";

      secretKeyFile = config.age.secrets.wealthfolio-key.path;

      authRequired = false;

      corsAllowOrigins = "http://wealthfolio, http://wealthfolio.${vpnDomain}";
    };

    services.caddy.virtualHosts = lib.mkIf caddyCfg.enable {
      "http://wealthfolio.${vpnDomain}, http://wealthfolio" = {
        extraConfig = ''
          bind tailscale/wealthfolio
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };
}
