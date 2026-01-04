{ ... }:

let
  wallpaper = ./wallpapers/nix-catppuccin-mocha.png;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ "${wallpaper}" ];
      wallpaper = [ ", ${wallpaper}" ];
    };
  };
}

