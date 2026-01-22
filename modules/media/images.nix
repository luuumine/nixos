{ pkgs, ... }:

{
  home.packages = with pkgs; [
    chafa
    imv
    krita
  ];
}
