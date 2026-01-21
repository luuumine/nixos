{ config, pkgs, ... }:

let
  modules = ../../../../modules;
  dev = "${modules}/dev";
in
{
  home-manager.users.lumine = {
    imports = [ 
      ./packages.nix
      ./zsh.nix
      ./hyprpaper.nix
      "${modules}/nvim.nix"
      "${modules}/dev/python.nix"
      "${modules}/dev/rust.nix"
      "${modules}/dev/nix.nix"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}

