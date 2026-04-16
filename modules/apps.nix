{
  config,
  lib,
  pkgs,
  ...
}:

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
    environment.systemPackages = [
      pkgs.bind
      pkgs.curl
      pkgs.file
      pkgs.git
      pkgs.lm_sensors
      pkgs.unzip
      pkgs.usbutils
      pkgs.vim
      pkgs.zip
    ]
    ++ cfg.extraSystemApps;

    home-manager.users.${userName} = {
      home.packages = [
        pkgs.fastfetch
        pkgs.htop
        pkgs.killall
        pkgs.stow
        pkgs.tree
      ]
      ++ cfg.extraUserApps;
    };
  };
}
