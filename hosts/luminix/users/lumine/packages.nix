{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
    brave
    btop
    discord-canary
    mangohud
    olympus
    prismlauncher
    qbittorrent
    rofi
  ];
}
