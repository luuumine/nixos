{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    btop
    discord-canary
    ffmpeg-full
    kitty
    mangohud
    mkvtoolnix
    mpv
    olympus
    prismlauncher
    qbittorrent
    rofi
  ];
}

