{ pkgs, ... }:

{
  home.packages = with pkgs; [
    easyeffects
    pavucontrol
    playerctl
    tenacity
  ];
}
