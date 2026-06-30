{ ... }:

{
  imports = [
    ./initrd-ssh.nix

    ./nvim
    ./network
    ./services
    ./security

    ./apps.nix
    ./audio.nix
    ./backups.nix
    ./bluetooth.nix
    ./desktop
    ./fonts.nix
    ./gaming
    ./git.nix
    ./media.nix
    ./nix.nix
    ./shell.nix
    ./starship.nix
    ./system.nix
    ./user.nix
  ];
}
