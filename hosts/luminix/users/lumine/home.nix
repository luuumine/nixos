{ config, modules, ... }:

{
  home-manager.users.lumine = {
    imports = [
      ./packages.nix
      "${modules}/home/core"
      "${modules}/home/desktop"
      "${modules}/home/media"
      "${modules}/home/dev"
    ];

    home.username = "lumine";
    home.homeDirectory = "/home/lumine";

    programs.home-manager.enable = true;

    home.stateVersion = "25.11";
  };
}
