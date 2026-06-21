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
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          ReconnectAttempts = 7;
          ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
          AutoEnable = true;
        };
      };
    };

    home-manager.users.${userName} = {
      home.packages = [ pkgs.bluetui ];
    };
  };
}
