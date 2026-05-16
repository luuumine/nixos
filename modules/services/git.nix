{ config, lib, ... }:

let
  cfg = config.lumine.services.git;
  caddyCfg = config.lumine.network.caddy;
  backupsCfg = config.lumine.backups;
in
{
  options.lumine.services.git = {
    enable = lib.mkEnableOption "local git forge instance";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "git.luuumine.com";
      description = "public domain for the forge";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3145;
    };
    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 3146;
    };
    dbType = lib.mkOption {
      type = lib.types.enum [
        "sqlite3"
        "mysql"
        "postgres"
      ];
      default = "postgres";
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      database.type = cfg.dbType;
      database.createDatabase = true;

      dump = {
        enable = backupsCfg.enable;
        backupDir = "${backupsCfg.zfsSourceDataset}/forgejo";
        type = "tar.xz";
      };

      settings = {
        server = {
          DOMAIN = cfg.domain;
          HTTP_PORT = cfg.port;
          ROOT_URL = "https://${cfg.domain}/";

          START_SSH_SERVER = true;
          SSH_PORT = cfg.sshPort;
          SSH_LISTEN_PORT = cfg.sshPort;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
      };
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
