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
          pkgs.libva-vdpau-driver
          pkgs.libvdpau-va-gl
          pkgs.intel-compute-runtime
          pkgs.vpl-gpu-rt
        ])
      ];
    };

    services.jellyfin = {
      enable = true;
      openFirewall = false;

      forceEncodingConfig = gpu != null;

      hardwareAcceleration = {
        enable = gpu != null;
        device = lib.mkIf (gpu != null) (lib.mkDefault "/dev/dri/renderD128");
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
      transcoding = lib.mkIf (gpu != null) {
        enableHardwareEncoding = true;
        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          vp8 = true;
          vp9 = true;
          vc1 = true;
          av1 = true;
          hevc10bit = true;
        };
        hardwareEncodingCodecs = {
          hevc = true;
          av1 = true;
        };
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

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."https://watch.luuumine.com".extraConfig = ''
        redir http://jellyfin.vpn.luuumine.com{uri}
      '';
      virtualHosts."http://jellyfin.vpn.luuumine.com, http://jellyfin" = {
        extraConfig = ''
          bind tailscale/jellyfin
          reverse_proxy 127.0.0.1:8096
        '';
      };
    };
  };
}
