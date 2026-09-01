{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:
let
  cfg = config.lumine.services.killer-game;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.killer-game = {
    enable = lib.mkEnableOption "Killer Game service";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "killer.luuumine.com";
      description = "public domain for the killer game";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4321;
      description = "the port the astro server responds on";
    };

    language = lib.mkOption {
      type = lib.types.enum [
        "en"
        "fr"
      ];
      default = "en";
      description = "game language for the ui";
    };
  };

  config = lib.mkIf cfg.enable {

    age.secrets."killer-game.env" = {
      file = secretsPath + "/${hostname}/killer-game.env.age";
    };

    systemd.services.killer-game = {
      description = "killer game astro server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        DynamicUser = true;

        StateDirectory = "killer-game";
        WorkingDirectory = "${pkgs.lumine.killer-game}";

        Environment = [
          "NODE_ENV=production"
          "PORT=${toString cfg.port}"
          "HOST=127.0.0.1"
          "BASE_URL=https://${cfg.domain}"
          "DB_PATH=/var/lib/killer-game/game.db"
          "LANG=${cfg.language}"
        ];

        EnvironmentFile = config.age.secrets."killer-game.env".path;

        ExecStart = "${pkgs.nodejs_22}/bin/node ${pkgs.lumine.killer-game}/dist/server/entry.mjs";
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
