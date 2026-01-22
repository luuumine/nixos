{ config, pkgs, ... }:

let
  modules = ../../../../modules;
  dev = "${modules}/dev";
in
{
  home-manager.users.lumine = {
    imports = [
      ./packages.nix
      "${modules}/core"
      "${modules}/desktop"
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
