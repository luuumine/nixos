{ config, lib, ... }:

let
  cfg = config.lumine.gaming;
in
{
  options.lumine.gaming.enable = lib.mkEnableOption "gaming utilities";

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
    hardware.wooting.enable = true;
  };
}
