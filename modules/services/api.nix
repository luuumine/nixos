{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:
let
  cfg = config.lumine.services.api;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.api = {
    enable = lib.mkEnableOption "api-lumine service";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "api.luuumine.com";
      description = "public domain for the api";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "the port the api responds on";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.api-lumine = {
      file = secretsPath + "/${hostname}/api-lumine.age";
    };

    systemd.services.api-lumine = {
      description = "lumine api service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "api-lumine";

        Environment = [
          "PORT=${toString cfg.port}"
          "NOTES_DB_URL=sqlite:///var/lib/api-lumine/notes.db?mode=rwc"
        ];

        EnvironmentFile = config.age.secrets.api-lumine.path;
        ExecStart = lib.getExe pkgs.lumine.api-lumine;
        Restart = "always";
      };
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
