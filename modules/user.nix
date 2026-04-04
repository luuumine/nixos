{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.user;
in
{
  options.lumine.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "lumine";
      description = "user account name";
    };
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "render"
        "video"
      ];
      initialPassword = "";
      shell = pkgs.zsh;
    };

    home-manager.users.${cfg.name} = {
      home.username = cfg.name;
      home.homeDirectory = "/home/${cfg.name}";
      programs.home-manager.enable = true;
      home.stateVersion = "25.11";
    };
  };
}
