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
      hostname = "luminout";
      gpuBrand = "amd";
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
