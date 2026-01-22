{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    btop
    discord-canary
    kitty
    mangohud
    olympus
    prismlauncher
    qbittorrent
    rofi
  ];
}

