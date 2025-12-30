{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./system.nix

    # Users
    ./users/lumine/home.nix
  ];

  # Identity & Localization
  networking.hostName = "luminix";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Sudo & Users
  security.sudo.wheelNeedsPassword = true;

  users.users.lumine = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Packages
  environment.systemPackages = with pkgs;
  [
    git
    nano
    vim
    neovim
    tree
    stow
    fastfetch
  ];

  system.stateVersion = "25.11";
}

