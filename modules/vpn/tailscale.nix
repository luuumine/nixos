{ config, lib, ... }:

let
  cfg = config.lumine.vpn.tailscale;
in
{
  options.lumine.vpn.tailscale = {
    enable = lib.mkEnableOption "tailscale client";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
