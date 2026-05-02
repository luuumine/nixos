{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminout";
      gpuBrand = "amd";
      bootloaderTimeout = 5;
    };

    nix.enable = true;

    apps.enable = true;

    network = {
      ssh.enable = true;
      tailscale.enable = true;
    };

    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
    bluetooth.enable = true;
  };
}
