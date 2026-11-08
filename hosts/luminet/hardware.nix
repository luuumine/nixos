{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "sd_mod"
    "sdhci_pci"
    "usb_storage"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  systemd.network.links."10-wan" = {
    # RTL8125, uses r8169
    matchConfig.MACAddress = "a0:1e:0b:13:b5:bd";
    linkConfig.Name = "wan";
  };

  systemd.network.links."10-lan" = {
    # I225-V, uses igc
    matchConfig.MACAddress = "a0:1e:0b:13:b5:bc";
    linkConfig.Name = "lan";
  };
}
