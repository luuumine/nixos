{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.automation;
  userName = config.lumine.user.name;
  caddyCfg = config.lumine.network.caddy;
in
{
  options.lumine.services.automation = {
    enable = lib.mkEnableOption "media automation";
  };

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = "media";
    };
    services.radarr = {
      enable = true;
      group = "media";
    };
    services.prowlarr.enable = true;
    services.flaresolverr.enable = true;

    services.seerr.enable = true;

    services.qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8888;
    };

    users.groups.media.members = [
      userName
      "sonarr"
      "radarr"
      "qbittorrent"
    ];

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts = {
        "http://requests.vpn.luuumine.com, http://requests".extraConfig = ''
          bind tailscale/requests
          reverse_proxy 127.0.0.1:5055
        '';
        "http://sonarr.vpn.luuumine.com, http://sonarr".extraConfig = ''
          bind tailscale/sonarr
          reverse_proxy 127.0.0.1:8989
        '';
        "http://radarr.vpn.luuumine.com, http://radarr".extraConfig = ''
          bind tailscale/radarr
          reverse_proxy 127.0.0.1:7878
        '';
        "http://prowlarr.vpn.luuumine.com, http://prowlarr".extraConfig = ''
          bind tailscale/prowlarr
          reverse_proxy 127.0.0.1:9696
        '';
        "http://flaresolverr.vpn.luuumine.com, http://flaresolverr".extraConfig = ''
          bind tailscale/flaresolverr
          reverse_proxy 127.0.0.1:8191
        '';
        "http://torrent.vpn.luuumine.com, http://torrent".extraConfig = ''
          bind tailscale/torrent
          reverse_proxy 127.0.0.1:8888
        '';
      };
    };
  };
}
