{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop-rocm
    fastfetch
    htop
    killall
    kitty
    stow
    tree
  ];
}
