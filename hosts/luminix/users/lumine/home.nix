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
      "${modules}/starship.nix"
      "${modules}/media"
      "${dev}/lua.nix"
      "${dev}/nix.nix"
      "${dev}/python.nix"
      "${dev}/rust.nix"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}
