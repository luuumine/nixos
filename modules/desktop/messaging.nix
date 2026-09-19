{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lumine.desktop.messaging;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.messaging = {
    enable = lib.mkEnableOption "messaging";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      home.packages = [
        pkgs.discord
        pkgs.signal-desktop
      ];
    };
  };
}
