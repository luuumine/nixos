{
  config,
  lib,
  loginServer,
  ...
}:

let
  cfg = config.lumine.network.tailscale;
  userName = config.lumine.user.name;
in
{
  options.lumine.network.tailscale = {
    enable = lib.mkEnableOption "tailscale client";
    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether this node should be an exit node";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.tailscale.members = [ userName ];

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      enable = true;
      useRoutingFeatures = if cfg.exitNode then "both" else "client";
    };

    services.tailscale.extraUpFlags = [
      "--login-server=${loginServer}"
    ]
    ++ lib.optional cfg.exitNode "--advertise-exit-node";

    boot.kernel.sysctl = lib.mkIf cfg.exitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
