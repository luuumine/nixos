{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/hardware/cpu/intel-npu.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    cpu.intel = {
      npu.enable = true;
      updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = false;
    };
  };

}
