{
  config,
  pkgs,
  inputs,
  ...
}:

let
  wallpapers = inputs.self.wallpapers;
  gpus = config.lumine.system.gpus;
in
{
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminix";
      gpus = {
        amd-igpu = {
          brand = "amd";
          path = "/dev/dri/by-path/pci-0000:7b:00.0-render";
        };
        rx9070xt = {
          brand = "amd";
          path = "/dev/dri/by-path/pci-0000:03:00.0-render";
        };
      };

      displayGpu = gpus.rx9070xt;

      bootloaderTimeout = 1;
      displays = [
        {
          output = "DP-1";
          mode = "2560x1440@240";
          position = "0x0";
          bitdepth = 10;
          wallpaper = wallpapers.isla-1;
        }
        {
          output = "DP-2";
          mode = "1920x1080@180";
          position = "-1920x240";
          wallpaper = wallpapers.isla-2;
        }
      ];
    };

    nix.enable = true;

    network = {
      ssh.enable = true;
      tailscale.enable = true;
    };

    gaming = {
      enable = true;
      steam.enable = true;
      minecraft.enable = true;
    };

    apps = {
      enable = true;
      extraSystemApps = [
        pkgs.age
      ];
      extraUserApps = [
        pkgs.discord
        pkgs.libresprite
        pkgs.mangohud
        pkgs.olympus
        pkgs.melonds
        pkgs.signal-desktop
      ];
    };

    desktop.enable = true;

    audio = {
      enable = true;
      loopback.enable = true;
    };
    media.enable = true;
    bluetooth.enable = true;

    fonts.enable = true;
    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
  };

  hardware.wooting.enable = true;
}
