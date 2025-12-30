{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    brave
    mangohud
    btop
    rofi
    vesktop
    olympus
  ];
}

