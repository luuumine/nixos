{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg-full
    mkvtoolnix
    mpv
  ];
}
