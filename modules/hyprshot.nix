{ config, lib, ... }:

let
  cfg = config.lumine.hyprshot;
  userName = config.lumine.user.name;
in
{
  options.lumine.hyprshot.enable = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.hyprshot = {
        enable = true;
        saveLocation = "${config.home.homeDirectory}/screenshots";
      };
    };
  };
}
