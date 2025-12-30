{ config, pkgs, ... }:

{
  home-manager.users.lumine = {
    imports = [ ./packages.nix ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}

