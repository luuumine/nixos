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
    nix.enable = true;
    audio.enable = true;
    bluetooth.enable = false;
    fonts.enable = true;
  };

  # Identity & Localization
  networking.hostName = "luminix";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # agenix
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Sudo & Users
  security.sudo.wheelNeedsPassword = true;

  users.users.lumine = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "render"
      "video"
    ];
    initialPassword = "";
  };

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
