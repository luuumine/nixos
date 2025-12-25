{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./storage.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Unlock Luks
  boot.initrd.secrets."/root/keys/data.key" = /root/keys/data.key;
  boot.initrd.luks.devices.cryptdata.keyFile = "/root/keys/data.key";

  # SSD Trim
  boot.initrd.luks.devices.cryptroot.allowDiscards = true;
  boot.initrd.luks.devices.cryptdata.allowDiscards = true;

  networking.hostName = "luminix"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # SSH
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  

  # Define users.
  users.users.lumine = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.sudo.wheelNeedsPassword = true;

  programs.hyprland.enable = true;
  services.hardware.openrgb.enable = true;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # System packages.
  environment.systemPackages = with pkgs; [
    nano
    vim
    neovim
    git
    kitty
    openrgb
    fastfetch
    brave
    mangohud
    rofi

    stow
    tree
  ];

  system.stateVersion = "25.11";

}

