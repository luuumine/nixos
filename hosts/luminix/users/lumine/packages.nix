{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    btop
    discord-canary
    kitty
    mangohud
    mpv
    olympus
    prismlauncher
    qbittorrent
    rofi
  ];
}

