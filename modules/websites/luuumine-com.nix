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
  frontend = inputs.luuumine-website.packages.${system}.frontend;
in
{
  imports = [ inputs.luuumine-website.nixosModules.default ];

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

    services.luuumine-backend = {
      enable = true;
      port = cfg.backendPort;
      envFile = config.age.secrets.luuumine-com-env.path;
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
