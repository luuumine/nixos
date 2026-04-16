{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./filesystem.nix
    ./vpn
  ];

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminix";
      gpuBrand = "amd";
    };

    nix.enable = true;

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
        pkgs.brave
        pkgs.discord-canary
        pkgs.mangohud
        pkgs.olympus
        pkgs.qbittorrent
        pkgs.rofi
        pkgs.osu-lazer-bin
      ];
    };

    ssh.enable = true;

    desktop.enable = true;

    audio.enable = true;
    media.enable = true;

    fonts.enable = true;
    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
    bluetooth.enable = false;
  };

  hardware.wooting.enable = true;
}
