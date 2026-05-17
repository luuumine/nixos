{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:

let
  cfg = config.lumine.services.git;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
  backupsCfg = config.lumine.backups;

  instance_key = {
    folder = "forgejo-ssh";
    name = "id_ed25519";
  };
in
{
  options.lumine.services.git = {
    enable = lib.mkEnableOption "local git forge instance";
    runners = lib.mkEnableOption "local native actions runner";

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

    age.secrets = lib.mkIf cfg.runners {
      forgejo-runner-token = {
        file = secretsPath + "/${hostname}/forgejo-runner-token.age";
      };
      forgejo-signing-key = {
        file = secretsPath + "/${hostname}/forgejo-signing-key.age";
        path = "/etc/${instance_key.folder}/${instance_key.name}";
        owner = "forgejo";
      };
    };
    environment.etc."${instance_key.folder}/${instance_key.name}.pub" = {
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpIOQUI+CJ527aWqxE5kxV58eL+sbgv1GWBKWbaTv77 forgejo@luuumine.com";
      mode = "0444";
    };

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
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        "repository.signing" = {
          FORMAT = "ssh";
          SIGNING_KEY = "/etc/${instance_key.folder}/${instance_key.name}.pub";
          SIGNING_NAME = "Forgejo";
          SIGNING_EMAIL = "forgejo@luuumine.com";
          INITIAL_COMMIT = "always";
          WIKI = "always";
          CRUD_ACTIONS = "always";
          MERGES = "always";
        };
      };
    };

    services.gitea-actions-runner = lib.mkIf cfg.runners {
      package = pkgs.forgejo-runner;
      instances = {
        "${hostname}" = {
          enable = true;
          name = hostname;
          url = "http://127.0.0.1:${toString cfg.port}";
          tokenFile = config.age.secrets.forgejo-runner-token.path;
          labels = [ "native:host" ];
          hostPackages = [
            pkgs.nix
            pkgs.nodejs
            pkgs.git
            pkgs.bash
            pkgs.openssh
            pkgs.fd
            pkgs.jq
            pkgs.ripgrep
          ];
          settings = {
            log.level = "info";
            runner = {
              file = ".runner";
              capacity = 5;
              timeout = "1h";
              insecure = false;
              fetch_timeout = "5s";
              fetch_interval = "2s";
            };
          };
        };
      };
    };
    systemd.services."gitea-runner-${hostname}" = {
      serviceConfig = {
        Environment = "HOME=/var/lib/gitea-runner/${hostname}";
      };
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
