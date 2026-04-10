{ lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      shell = pkgs.zsh;
      hostname = "luminova";
    };

    nix.enable = true;

    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
  };
}
