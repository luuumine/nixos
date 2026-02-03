{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # For 'qmlls' and 'qmlformat'
    kdePackages.qtdeclarative
  ];
}
