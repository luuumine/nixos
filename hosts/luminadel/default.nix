{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;

  users.users.lumine.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX"
  ];

  lumine = {
    initrd-ssh = {
      enable = true;
      port = 49152;
      networkDrivers = [ "r8169" ];
    };

    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminadel";
      gpuBrand = "intel";
    };

    nix.enable = true;

    apps.enable = true;

    network = {
      ssh.enable = true;
      caddy.enable = true;
      headscale.enable = true;
      tailscale = {
        enable = true;
        exitNode = true;
      };
      mullvad.enable = true;
    };

    services = {
      jellyfin.enable = true;
      automation.enable = true;
    };

    websites = {
      luuumine-com.enable = true;
      delhommais-com.enable = true;
    };

    shell.enable = true;
    starship = {
      enable = true;
      theme = {
        username = "bold #C77DFF";
        symbol = "bold #E3B505";
        hostname = "bold #C77DFF";
        directory = "bold yellow";
      };
    };
    git.enable = true;
    nvim.enable = true;
  };

}
