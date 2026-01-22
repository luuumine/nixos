{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    fastfetch
    htop
    killall
    kitty
    stow
    tree
  ];
}
