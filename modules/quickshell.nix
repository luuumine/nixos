{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.quickshell;
  userName = config.lumine.user.name;
in
{
  options.lumine.quickshell.enable = lib.mkEnableOption "quiskehll";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        quickshell
      ];
    };
  };
}
