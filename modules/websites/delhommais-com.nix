{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.lumine.websites.delhommais-com;
  caddyCfg = config.lumine.network.caddy;

  system = pkgs.stdenv.hostPlatform.system;
  frontend = inputs.delhommais-website.packages.${system}.default;
in
{
  options.lumine.websites.delhommais-com = {
    enable = lib.mkEnableOption "delhommais.com website hosting";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = caddyCfg.enable;
        message = "caddy must be enabled to host delhommais.com";
      }
    ];

    services.caddy.virtualHosts."delhommais.com, www.delhommais.com".extraConfig = ''
      root * ${frontend}
      try_files {path} {path}/ {path}.html
      file_server

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
