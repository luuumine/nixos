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

  # Identity & Localization
  networking.hostName = "luminix";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    use-xdg-base-directories = true;
  };
  nixpkgs.config.allowUnfree = true;

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
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Packages
  environment.systemPackages = with pkgs;
  [
    bind
    curl
    eza
    fastfetch
    file
    git
    htop
    killall
    lm_sensors
    pciutils
    stow
    tree
    unzip
    usbutils
    vim
    wget
    zip
  ];

  system.stateVersion = "25.11";
}

