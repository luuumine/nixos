{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lumine.services.jellyfin;
  userName = config.lumine.user.name;
  caddyCfg = config.lumine.network.caddy;
  types = import ../types { inherit lib; };
in
{
  options.lumine.services.jellyfin = {
    enable = lib.mkEnableOption "jellyfin media server";
    gpu = lib.mkOption {
      type = lib.types.nullOr types.gpu;
      default = null;
      description = "gpu submodule to use for transcoding";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = lib.mkIf (cfg.gpu != null) {
      enable = true;
      extraPackages = lib.mkIf (cfg.gpu.brand == "intel") [
        pkgs.intel-media-driver
        pkgs.intel-vaapi-driver
        pkgs.libva-vdpau-driver
        pkgs.libvdpau-va-gl
        pkgs.intel-compute-runtime
        pkgs.vpl-gpu-rt
      ];
    };

    services.jellyfin = {
      enable = true;
      openFirewall = false;

      forceEncodingConfig = cfg.gpu != null;

      hardwareAcceleration = {
        enable = cfg.gpu != null;
        device = lib.mkIf (cfg.gpu != null && cfg.gpu.path != null) cfg.gpu.path;
        type =
          if cfg.gpu == null then
            "none"
          else if cfg.gpu.brand == "intel" then
            "qsv"
          else if cfg.gpu.brand == "amd" then
            "amf"
          else if cfg.gpu.brand == "nvidia" then
            "nvenc"
          else
            "none";
      };
      transcoding = lib.mkIf (cfg.gpu != null) {
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
