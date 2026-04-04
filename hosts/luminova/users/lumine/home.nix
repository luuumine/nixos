{ config, modules, ... }:

{
  home-manager.users.lumine = {
    imports = [
      # "${modules}/home/core"
      # "${modules}/home/dev"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}
