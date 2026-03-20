{ pkgs, modules, ... }:

{
  imports = [
    ./storage.nix
    ./system.nix
    "${modules}/nixos"
  ];

  networking.hostName = "luminova";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  security.sudo.wheelNeedsPassword = true;

  users.users.lumine = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
    ];
    initialPassword = "";
  };

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
