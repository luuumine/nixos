{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.lumine.desktop.quickshell;
  userName = config.lumine.user.name;
  system = pkgs.stdenv.hostPlatform.system;
  quickshell-lumine = inputs.self.packages.${system}.quickshell-lumine;
in
{
  options.lumine.desktop.quickshell.enable = lib.mkEnableOption "quickshell";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.quickshell = {
        enable = true;
        configs = {
          "lumine" = quickshell-lumine;
        };
        activeConfig = "lumine";
        systemd.enable = true;
      };
    };
  };
}
