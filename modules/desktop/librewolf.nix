{ config, lib, ... }:

let
  cfg = config.lumine.desktop.librewolf;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.librewolf.enable = lib.mkEnableOption "librewolf";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.librewolf.enable = true;
    };
  };
}
