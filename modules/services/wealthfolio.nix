{
  config,
  lib,
  pkgs,
  inputs,
  secretsPath,
  ...
}:

let
  cfg = config.lumine.services.wealthfolio;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.lumine.services.wealthfolio = {
    enable = lib.mkEnableOption "local wealthfolio server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "wealth.luuumine.com";
      description = "public domain for wealthfolio";
    };

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

      package = inputs.self.packages.${system}.wealthfolio-server; # local copy until upstream push

      secretKeyFile = config.age.secrets.wealthfolio-key.path;

      authRequired = false;
      corsAllowOrigins = "https://${cfg.domain}";
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
