{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.lumine.services.luuumine-com;
  caddyCfg = config.lumine.network.caddy;

  system = pkgs.stdenv.hostPlatform.system;
  frontend = inputs.self.packages.${system}.luuumine-com;
in
{
  options.lumine.services.luuumine-com = {
    enable = lib.mkEnableOption "luuumine.com website hosting";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = caddyCfg.enable;
        message = "caddy must be enabled to host luuumine.com";
      }
    ];

    services.caddy.virtualHosts."luuumine.com, www.luuumine.com".extraConfig = ''
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
