{ config, ... }:

let
  gpus = config.lumine.system.gpus;
in
{
  imports = [
    ./hardware.nix
    ./filesystem.nix
    ./backups.nix
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
      gpus = {
        intel-igpu = {
          brand = "intel";
          path = "/dev/dri/by-path/pci-0000:00:02.0-render";
        };
        rtx3060 = {
          brand = "nvidia";
          path = "/dev/dri/by-path/pci-0000:7b:00.0-render";
        };
      };
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

    services = {
      api.enable = true;

      delhommais-com.enable = true;
      luuumine-com.enable = true;

      minecraft = {
        enable = true;
        serverProperties = {
          difficulty = "hard";
          "level-seed" = "19104373647";
          "max-players" = 428;
          "view-distance" = 16;
          "simulation-distance" = 16;
          "white-list" = true;
          "enforce-whitelist" = true;
        };
        whitelist = {
          lumine = "076119e3-c0cf-48fb-8d1f-0a637f5f44ac";
        };
      };

      jellyfin = {
        enable = true;
        gpu = gpus.intel-igpu;
      };
      automation.enable = true;
      immich = {
        enable = true;
        gpu = gpus.intel-igpu;
      };
      git = {
        enable = true;
        runners = true;
      };
      vaultwarden.enable = true;
      wealthfolio.enable = true;

      ai = {
        enable = true;
        gpu = gpus.rtx3060;
        model = "/models/bartowski/gemma-4-12B-it-Q4_K_M.gguf";
        contextSize = 131072;
        parallelSessions = 2;
        gpuLayers = "all";
      };

      killer-game = {
        enable = true;
        language = "fr";
      };
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
