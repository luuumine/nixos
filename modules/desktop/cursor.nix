{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lumine.desktop.cursor;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.cursor.enable = lib.mkEnableOption "cursor configuration";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        hyprcursor.enable = true;
        x11.enable = true;

        size = 24;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };
  };
}
