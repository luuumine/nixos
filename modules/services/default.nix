{ ... }:
{
  imports = [
    ./api.nix

    ./delhommais-com.nix
    ./luuumine-com.nix

    ./minecraft.nix

    ./killer-game.nix

    ./jellyfin.nix
    ./automation.nix
    ./immich.nix
    ./git.nix
    ./vaultwarden.nix
    ./wealthfolio.nix
    ./ai.nix
    ./opengym.nix

    # https://github.com/NixOS/nixpkgs/pull/566279
    ./opengym-module.nix
  ];
}
