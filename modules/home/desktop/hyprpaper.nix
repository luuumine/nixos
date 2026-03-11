{ ... }:

let
  wallpapers = import ./wallpapers;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ "${wallpapers.mocha}" ];
      wallpaper = [ ", ${wallpapers.mocha}" ];
    };
  };
}
