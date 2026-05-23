{
  config,
  lib,
  pkgs,
  inputs,
  secretsPath,
  ...
}:
let
  cfg = config.lumine.services.api;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;

  system = pkgs.stdenv.hostPlatform.system;
  api-lumine = inputs.self.packages.${system}.api-lumine;
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
        Environment = "PORT=${toString cfg.port}";
        EnvironmentFile = config.age.secrets.api-lumine.path;
        ExecStart = lib.getExe api-lumine;
        Restart = "always";
      };
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://api.luuumine.com".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
