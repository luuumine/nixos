{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.opengym;
  caddyCfg = config.lumine.network.caddy;

  domain = "gym.luuumine.com";
in
{
  options.lumine.services.opengym = {
    enable = lib.mkEnableOption "openGym server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.opengym = {
      enable = true;
      inherit (cfg) port;

      package = pkgs.lumine.opengym-api;

      rpId = domain;
      origin = "https://${domain}";

      inviteOnly = false;
      adminUids = [ ];

      reverseProxy = {
        enable = caddyCfg.enable;
        hostName = "https://${domain}";
      };
    };
  };
}
