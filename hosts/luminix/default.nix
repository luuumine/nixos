{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./system.nix
    ./vpn

    # Users
    ./users/lumine/home.nix
  ];

  lumine = {
    system.hostname = "luminix";
    user.name = "lumine";

    nix.enable = true;
    audio.enable = true;
    bluetooth.enable = false;
    fonts.enable = true;

  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Packages
  environment.systemPackages = with pkgs; [
    bind
    curl
    file
    git
    lm_sensors
    pciutils
    unzip
    usbutils
    vim
    wget
    zip
  ];

  system.stateVersion = "25.11";
}
