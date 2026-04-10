{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./vpn
  ];

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      shell = pkgs.bash;
      hostname = "luminix";
      gpuBrand = "amd";
    };

    nix.enable = true;

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
        pkgs.prismlauncher
        pkgs.qbittorrent
        pkgs.rofi
      ];
    };

    desktop.enable = true;
    gaming.enable = true;

    audio.enable = true;
    media.enable = true;

    fonts.enable = true;
    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
    bluetooth.enable = false;
  };
}
