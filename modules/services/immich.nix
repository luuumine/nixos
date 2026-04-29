{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.immich;
  userName = config.lumine.user.name;
  gpu = config.lumine.system.gpuBrand;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.immich = {
    enable = lib.mkEnableOption "immich photo server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = "immich internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = lib.mkMerge [
        (lib.mkIf (gpu == "intel") [
          pkgs.intel-media-driver
          pkgs.intel-vaapi-driver
        ])
      ];
    };

    services.immich = {
      enable = true;
      port = cfg.port;
      host = "127.0.0.1";
      openFirewall = false;
      machine-learning.enable = (gpu != null);
      accelerationDevices = lib.mkIf (gpu != null) [ "/dev/dri/renderD128" ];
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
