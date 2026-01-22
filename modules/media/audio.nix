{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pavucontrol
    playerctl
    tenacity
  ];
}
