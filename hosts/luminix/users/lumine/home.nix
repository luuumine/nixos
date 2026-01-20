{ config, pkgs, ... }:

{
  home-manager.users.lumine = {
    imports = [ 
      ./packages.nix
      ./zsh.nix
      ./hyprpaper.nix
      ../../../../modules/nvim.nix
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}

