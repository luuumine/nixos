{ ... }:

{
  imports = [
    ./initrd-ssh.nix

    ./network
    ./services
    ./websites

    ./apps.nix
    ./audio.nix
    ./bluetooth.nix
    ./desktop
    ./fonts.nix
    ./gaming
    ./git.nix
    ./media.nix
    ./nix.nix
    ./nvim.nix
    ./shell.nix
    ./starship.nix
    ./system.nix
    ./user.nix
  ];
}
