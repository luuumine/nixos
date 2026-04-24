{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lumine.services.jellyfin;
  userName = config.lumine.user.name;
  gpu = config.lumine.system.gpuBrand;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.jellyfin = {
    enable = lib.mkEnableOption "jellyfin media server";
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

    services.jellyfin = {
      enable = true;
      openFirewall = false;

      hardwareAcceleration = {
        enable = gpu != null;
        device = "/dev/dri/renderD128";
        type =
          if gpu == "intel" then
            "qsv"
          else if gpu == "amd" then
            "amf"
          else if gpu == "nvidia" then
            "nvenc"
          else
            "none";
      };
    };

    users.groups.media.members = [
      userName
      "jellyfin"
    ];
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    systemd.tmpfiles.rules = [
      "d /media 0775 root media - -"
    ];

    lumine.network.caddy.localService.jellyfin = lib.mkIf caddyCfg.enable 8096;
    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://watch.luuumine.com".extraConfig = ''
        bind tailscale/jellyfin
        reverse_proxy 127.0.0.1:8096
      '';
    };
  };
}
