{ ... }:

{
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
}

