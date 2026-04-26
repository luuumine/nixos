{
  config,
  lib,
  loginServer,
  secretsPath,
  vpnDomain,
  ...
}:

let
  cfg = config.lumine.network.headscale;
  userName = config.lumine.user.name;
  hostname = config.lumine.system.hostname;
in
{
  options.lumine.network.headscale = {
    enable = lib.mkEnableOption "headscale control server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "internal headscale port";
    };
    headplane = {
      enable = lib.mkEnableOption "headplane ui for headscale";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "internal headplane port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.headscale.members = [ userName ];

    age.secrets = lib.mkIf cfg.headplane.enable {
      headplane_cookie = {
        file = secretsPath + "/${hostname}/headplane_cookie.age";
        owner = "headscale";
      };
      headscale_api_key = {
        file = secretsPath + "/${hostname}/headscale_api_key.age";
        owner = "headscale";
      };
    };

    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = cfg.port;
      settings = {
        unix_socket_permission = "0770";
        policy.mode = "database";
        server_url = "https://${loginServer}";
        dns = {
          magic_dns = true;
          base_domain = vpnDomain;
          nameservers.global = [ "1.1.1.1" ];
        };
      };
    };

    services.headplane = lib.mkIf cfg.headplane.enable {
      enable = true;
      settings = {
        server = {
          host = "127.0.0.1";
          port = cfg.headplane.port;
          cookie_secret_path = config.age.secrets.headplane_cookie.path;
          cookie_secure = false; # allow serving over http
        };
        headscale = {
          url = "http://127.0.0.1:${toString cfg.port}";
          public_url = "https://${loginServer}";
          api_key_path = config.age.secrets.headscale_api_key.path;
        };
      };

    };

    services.caddy.virtualHosts = {
      ${loginServer}.extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
      "http://plane.${vpnDomain}, http://plane" = lib.mkIf cfg.headplane.enable {
        extraConfig = ''
          bind tailscale/plane
          reverse_proxy 127.0.0.1:${toString cfg.headplane.port}
        '';
      };
    };
  };
}
