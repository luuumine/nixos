{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "fd4d47e3";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/f99b46ec-1178-4ed9-a8f7-37b8b1c070bc";
    allowDiscards = true;
  };

  boot.initrd.systemd.services."zfs-import-zroot" = {
    requires = [ "dev-mapper-cryptroot.device" ];
    after = [ "dev-mapper-cryptroot.device" ];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/D9DC-4150";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/" = {
      device = "zroot/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "zroot/home";
      fsType = "zfs";
    };

    "/games" = {
      device = "zroot/games";
      fsType = "zfs";
    };
  };

}
