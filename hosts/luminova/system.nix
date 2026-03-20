{ pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "nvme"
    "uas"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.preDeviceCommands = "sleep 5";

  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
    consoleMode = "max";
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.timeout = 5;

  console = {
    font = "ter-v16b";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  networking.networkmanager.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
