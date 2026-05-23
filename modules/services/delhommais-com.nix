{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.lumine.services.delhommais-com;
  caddyCfg = config.lumine.network.caddy;

  system = pkgs.stdenv.hostPlatform.system;
  frontend = inputs.self.packages.${system}.delhommais-com;
in
{
  options.lumine.services.delhommais-com = {
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

      handle_errors {
        redir https://delhommais.com temporary # 302
      }
    '';
  };
}
