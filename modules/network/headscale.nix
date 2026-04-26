{
  config,
  lib,
  loginServer,
  vpnDomain,
  ...
}:

let
  cfg = config.lumine.network.headscale;
  userName = config.lumine.user.name;
in
{
  options.lumine.network.headscale = {
    enable = lib.mkEnableOption "headscale control server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "internal headscale port";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.headscale.members = [ userName ];

    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.port;
      settings = {
        unix_socket_permission = "0770";
        server_url = "https://${loginServer}";
        dns = {
          magic_dns = true;
          base_domain = vpnDomain;
          nameservers.global = [ "1.1.1.1" ];
        };
      };
    };

    services.caddy.virtualHosts.${loginServer}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
