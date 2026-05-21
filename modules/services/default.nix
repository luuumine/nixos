{ ... }:
{
  imports = [
    ./jellyfin.nix
    ./automation.nix
    ./immich.nix
    ./git.nix
    ./wealthfolio.nix

    ./wealthfolio-module.nix # local copy until upstream push

  ];
}
