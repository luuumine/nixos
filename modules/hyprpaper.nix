{ config, lib, ... }:

let
  cfg = config.lumine.hyprpaper;
  userName = config.lumine.user.name;
  wallpapers = import ./wallpapers;
  monitorWallpapers = {
    "DP-1" = wallpapers.isla-nix;
    "DP-2" = wallpapers.isla-figure;
  };
in
{
  options.lumine.hyprpaper.enable = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;

          preload = map toString (builtins.attrValues monitorWallpapers);

          wallpaper = lib.attrsets.mapAttrsToList (
            monitor: path: "${monitor}, ${toString path}"
          ) monitorWallpapers;
        };
      };
    };
  };
}
