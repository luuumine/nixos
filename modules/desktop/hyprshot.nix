{ config, lib, ... }:

let
  cfg = config.lumine.desktop.hyprshot;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.hyprshot.enable = lib.mkEnableOption "hyprshot";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} =
      { config, ... }:
      {
        programs.hyprshot = {
          enable = true;
          saveLocation = "${config.home.homeDirectory}/screenshots";
        };
      };
  };
}
