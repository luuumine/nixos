{
  config,
  lib,
  pkgs,
  inputs,
  secretsPath,
  ...
}:
let
  cfg = config.lumine.websites.luuumine-com;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;

  system = pkgs.stdenv.hostPlatform.system;
  frontend = inputs.self.packages.${system}.luuumine-com-frontend;
  backend = inputs.self.packages.${system}.luuumine-com-backend;
in
{
  options.lumine.websites.luuumine-com = {
    enable = lib.mkEnableOption "luuumine.com website hosting";
    backendPort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "the port the backend responds on";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = caddyCfg.enable;
        message = "caddy must be enabled to host luuumine.com";
      }
    ];

    age.secrets.luuumine-com-env = {
      file = secretsPath + "/${hostname}/luuumine-com-env.age";
    };

    systemd.services.luuumine-com-backend = {
      description = "luuumine.com api";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        Environment = "PORT=${toString cfg.backendPort}";
        EnvironmentFile = config.age.secrets.luuumine-com-env.path;
        ExecStart = lib.getExe backend;
        Restart = "always";
      };
    };

    services.caddy.virtualHosts."luuumine.com, www.luuumine.com".extraConfig = ''
      root * ${frontend}
      try_files {path} {path}/ {path}.html
      file_server

      handle /api/* {
        reverse_proxy 127.0.0.1:${toString cfg.backendPort}
      }

      handle_errors 404 {
        rewrite * /404.html
        file_server
      }

      handle_errors {
        respond "{err.status_code} {err.status_text}"
      }
    '';
  };
}
