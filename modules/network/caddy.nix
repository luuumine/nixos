{
  config,
  lib,
  pkgs,
  secretsPath,
  vpnDomain,
  ...
}:

let
  cfg = config.lumine.network.caddy;

  tsCfg = config.lumine.network.tailscale;
  hsCfg = config.lumine.network.headscale;

  hostname = config.lumine.system.hostname;
in
{
  options.lumine.network.caddy = {
    enable = lib.mkEnableOption "caddy reverse proxy";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets.caddy_env = {
      file = secretsPath + "/${hostname}/caddy.age";
      owner = "caddy";
      group = "caddy";
    };

    services.caddy = {
      enable = true;
      environmentFile = config.age.secrets.caddy_env.path;

      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
          "github.com/tailscale/caddy-tailscale@v0.0.0-20260106222316-bb080c4414ac"
        ];
        hash = "sha256-TAg2e7r6du1b2CY81x63yGPJ59mjvzdOKcuno+Klaa8=";
      };

      globalConfig = ''
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}

        tailscale {
          auth_key {env.TS_AUTHKEY}
          control_url {env.TS_BASE_URL}
        }
      '';
    };

    systemd.services.caddy = {
      after =
        lib.optional tsCfg.enable "tailscaled.service" ++ lib.optional hsCfg.enable "headscale.service";

      environment = lib.mkIf hsCfg.enable {
        TS_BASE_URL = "http://127.0.0.1:${toString hsCfg.port}";
      };
    };
  };
}
