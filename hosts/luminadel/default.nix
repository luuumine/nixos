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
      hostname = "luminadel";
      gpuBrand = "intel";
    };

    nix.enable = true;

    apps.enable = true;

    network = {
      ssh.enable = true;
      caddy.enable = true;
      headscale = {
        enable = true;
        port = 8080;
        headplane = {
          enable = true;
          port = 8081;
        };
      };
      tailscale = {
        enable = true;
        exitNode = true;
      };
      mullvad.enable = true;
    };

    backups = {
      enable = true;
      isSender = true;
      zfsSourceDataset = "ZROOT/backups";
      localSinkPools = [ "TANK/backups" ];
      remoteSinks = [ "luminode" ];
      interval = {
        local = "1h";
        remote = "1h";
      };
    };

    services = {
      jellyfin.enable = true;
      automation.enable = true;
      immich.enable = true;
      git = {
        enable = true;
        runners = true;
      };
      wealthfolio.enable = true;
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
