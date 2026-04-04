{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.bluetooth;
  userName = config.lumine.user.name;
in
{
  options.lumine.bluetooth = {
    enable = lib.mkEnableOption "system bluetooth";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };

    home-manager.users.${userName} = {

      home.packages = [ pkgs.bluetui ];
    };
  };
}
