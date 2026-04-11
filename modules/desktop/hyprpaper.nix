{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop.hyprpaper;
  userName = config.lumine.user.name;
  wallpapers = import ./wallpapers.nix { inherit pkgs; };
  monitorWallpapers = {
    "DP-1" = wallpapers.isla-1;
    "DP-2" = wallpapers.isla-2-figure;
  };
in
{
  options.lumine.desktop.hyprpaper.enable = lib.mkEnableOption "hyprpaper";

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
