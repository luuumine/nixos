{ config, pkgs, ... }:

let
  modules = ../../../../modules;
in
{
  home-manager.users.lumine = {
    imports = [
      ./packages.nix
      "${modules}/core"
      "${modules}/desktop"
      "${modules}/media"
      "${modules}/dev"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}
