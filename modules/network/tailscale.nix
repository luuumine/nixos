{ config, lib, ... }:

let
  cfg = config.lumine.network.tailscale;
in
{
  options.lumine.network.tailscale = {
    enable = lib.mkEnableOption "tailscale client";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
