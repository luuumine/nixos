{
  config,
  lib,
  secretsPath,
  ...
}:

let
  cfg = config.lumine.services.vaultwarden;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden password manager";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "vault.luuumine.com";
      description = "public domain for the vault";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };

    dbType = lib.mkOption {
      type = lib.types.enum [
        "sqlite"
        "mysql"
        "postgresql"
      ];
      default = "sqlite";
    };

    enableBackups = lib.mkEnableOption "automated db dumps";
  };

  config = lib.mkIf cfg.enable {

    age.secrets.vaultwarden = {
      file = secretsPath + "/${hostname}/vaultwarden.age";
      owner = "vaultwarden";
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = cfg.dbType;

      backupDir = lib.mkIf cfg.enableBackups "/backups/vaultwarden";

      environmentFile = config.age.secrets.vaultwarden.path;

      config = {
        DOMAIN = "https://${cfg.domain}";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;
      };
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
