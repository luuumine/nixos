{ pkgs, ... }:

{
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Luks & SSD
  boot.initrd.secrets."/root/keys/data.key" = /root/keys/data.key;
  boot.initrd.luks.devices.cryptdata.keyFile = "/root/keys/data.key";

  boot.initrd.luks.devices.cryptroot.allowDiscards = true;
  boot.initrd.luks.devices.cryptdata.allowDiscards = true;

  # System-level services
  services.xserver.videoDrivers = [ "amdgpu" ];
  programs.hyprland.enable = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  hardware.wooting.enable = true;

  networking.networkmanager.enable = true;

  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    documentation = ["man:systemd.special(7)"];
    bindsTo = ["graphical-session.target"];
    wants = ["graphical-session-pre.target"];
    after = ["graphical-session-pre.target"];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}

