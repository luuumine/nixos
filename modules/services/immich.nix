{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.immich;
  userName = config.lumine.user.name;
  caddyCfg = config.lumine.network.caddy;
  types = import ../types { inherit lib; };
in
{
  options.lumine.services.immich = {
    enable = lib.mkEnableOption "immich photo server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = "immich internal port";
    };
    gpu = lib.mkOption {
      type = lib.types.nullOr types.gpu;
      default = null;
      description = "gpu submodule for ML and transcoding";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = lib.mkIf (cfg.gpu != null) {
      enable = true;
      extraPackages = lib.mkIf (cfg.gpu.brand == "intel") [
        pkgs.intel-media-driver
        pkgs.intel-vaapi-driver
      ];
    };

    services.immich = {
      enable = true;
      port = cfg.port;
      host = "127.0.0.1";
      openFirewall = false;
      machine-learning.enable = (cfg.gpu != null);
      accelerationDevices = lib.mkIf (cfg.gpu != null && cfg.gpu.path != null) [ cfg.gpu.path ];
    };

    users.groups.immich.members = [ userName ];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];

    systemd.tmpfiles.settings.immich = {
      "/var/lib/immich".e.mode = lib.mkForce "0750";
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://photos.delhommais.com".extraConfig = ''
        request_body {
          max_size 5000MB
        }
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
