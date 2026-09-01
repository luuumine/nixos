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
  options.lumine.desktop.quickshell.enable = lib.mkEnableOption "quickshell";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.quickshell = {
        enable = true;
        configs = {
          "lumine" = pkgs.lumine.quickshell-lumine;
        };
        activeConfig = "lumine";
        systemd.enable = true;
      };
    };
  };
}
