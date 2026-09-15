{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.opengym;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.opengym = {
    enable = lib.mkEnableOption "opengym workout tracker";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "gym.luuumine.com";
      description = "public domain for the opengym instance";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3030;
      description = "internal port for the opengym api";
    };

    inviteOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether new profiles require an invite code";
    };

    allowGuest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to allow continue without account";
    };

    adminUids = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "list of admin user ids";
    };
  };

  config = lib.mkIf cfg.enable {
    services.opengym = {
      enable = true;
      package = pkgs.lumine.opengym-api;

      inherit (cfg)
        port
        inviteOnly
        allowGuest
        adminUids
        ;

      rpId = cfg.domain;
      origin = "https://${cfg.domain}";

      reverseProxy = {
        enable = caddyCfg.enable;
        hostName = "https://${cfg.domain}";
      };
    };
  };
}
