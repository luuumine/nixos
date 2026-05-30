{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop.hyprpaper;
  userName = config.lumine.user.name;

  displays = config.lumine.system.displays;
  displaysWithWallpaper = lib.filter (d: d.wallpaper != null) displays;
in
{
  options.lumine.desktop.hyprpaper.enable = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;

          preload = lib.unique (map (d: toString d.wallpaper) displaysWithWallpaper);

          wallpaper = map (d: {
            monitor = d.output;
            path = toString d.wallpaper;
          }) displaysWithWallpaper;
        };
      };
    };
  };
}
