{ ... }:

{
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

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
      hostname = "luminode";
      gpuBrand = "amd";
    };

    nix.enable = true;

    network = {
      ssh.enable = true;
      tailscale.enable = true;
    };

    shell.enable = true;
    starship = {
      enable = true;
      theme = {
        username = "bold #FAB387";
        symbol = "bold #94E2D5";
        hostname = "bold #FAB387";
        directory = "bold #74C7EC";
      };
    };
    git.enable = true;
    nvim.enable = true;
  };
}
