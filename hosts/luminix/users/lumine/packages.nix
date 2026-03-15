{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
    brave
    discord-canary
    mangohud
    olympus
    prismlauncher
    qbittorrent
    rofi
  ];
}
