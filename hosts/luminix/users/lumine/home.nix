{ config, modulesFolder, ... }:

{
  home-manager.users.lumine = {
    imports = [
      ./packages.nix
      "${modulesFolder}/core"
      "${modulesFolder}/desktop"
      "${modulesFolder}/media"
      "${modulesFolder}/dev"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}
