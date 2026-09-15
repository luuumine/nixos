{
  config,
  inputs,
  pkgs,
  lib,
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

  lumine.services.opengym.enable = true;
  services.opengym = {
    rpId = lib.mkForce "localhost";
    origin = lib.mkForce "http://localhost:8080";
    vapidSubject = lib.mkForce "mailto:test@example.com";

    reverseProxy = {
      enable = lib.mkForce true;
      hostName = lib.mkForce "localhost:8080";
    };
  };

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminout";
      gpus = {
        amd-igpu = {
          brand = "amd";
        };
        rx6700m = {
          brand = "amd";
        };
      };
      displayGpu = gpus.rx6700m;
      bootloaderTimeout = 5;
      displays = [
        {
          output = "eDP-1";
          mode = "1920x1080@240";
          wallpaper = wallpapers.isla-1;
        }
      ];
    };

    nix.enable = true;

    network = {
      ssh.enable = true;
      tailscale.enable = true;
    };

    apps = {
      enable = true;
      extraUserApps = [
        pkgs.discord
      ];
    };

    desktop.enable = true;

    audio.enable = true;
    media.enable = true;
    bluetooth.enable = true;

    fonts.enable = true;
    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
  };
}
