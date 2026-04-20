{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  users.users.lumine.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX	"
  ];

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminadel";
      gpuBrand = "intel";
    };

    nix.enable = true;

    ssh.enable = true;

    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
  };

}
