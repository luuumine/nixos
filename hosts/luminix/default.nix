{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./system.nix
    ./vpn
  ];

  lumine = {
    user.name = "lumine";
    system = {
      enable = true;
      shell = pkgs.bash;
      hostname = "luminix";
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

    audio.enable = true;
    fonts.enable = true;
    terminal.enable = true;
    shell.enable = true;
    starship.enable = true;
    git.enable = true;
    nvim.enable = true;
    bluetooth.enable = false;

    hyprpaper.enable = true;
    hyprshot.enable = true;
    quickshell.enable = true;
  };
}
