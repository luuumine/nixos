{ config, lib, ... }:

let
  cfg = config.lumine.gaming.steam;
in
{
  options.lumine.gaming.steam.enable = lib.mkEnableOption "steam config";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
}
