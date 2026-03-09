{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
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
