{ lib, ... }:

let
  wallpapers = import ./wallpapers;
  monitorWallpapers = {
    "DP-1" = wallpapers.isla-nix;
    "DP-2" = wallpapers.isla-figure;
  };
in
{
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
}
