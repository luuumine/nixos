{ pkgs, inputs, ... }:

let
  wallpapers = inputs.self.wallpapers;
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
      gpuBrand = "amd";
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
        pkgs.rofi
        pkgs.osu-lazer-bin
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

  hardware.wooting.enable = true;
}
