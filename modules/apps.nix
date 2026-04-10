{ config, lib, ... }:

let
  cfg = config.lumine.apps;
  userName = config.lumine.user.name;
in
{
  options.lumine.apps = {
    enable = lib.mkEnableOption "general applications";
    extraSystemApps = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "list of packages to install for the system";
    };

    extraUserApps = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "list of packages to install for the user";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.extraSystemApps;
    home-manager.users.${userName} = {
      home.packages = cfg.extraUserApps;
    };
  };
}
