{
  config,
  lib,
  secretsPath,
  ...
}:
let
  cfg = config.lumine.services.harmonia;
  hostname = config.lumine.system.hostname;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.harmonia = {
    enable = lib.mkEnableOption "harmonia binary cache";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "cache.luuumine.com";
      description = "domain for the binary cache";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "the port harmonia responds on";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.harmonia = {
      file = secretsPath + "/${hostname}/harmonia.age";
      mode = "0400";
    };

    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [ config.age.secrets.harmonia.path ];
      settings.bind = "127.0.0.1:${toString cfg.port}";
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
