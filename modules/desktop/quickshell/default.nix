{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop.quickshell;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.quickshell.enable = lib.mkEnableOption "quiskehll";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        quickshell
      ];
    };
  };
}
