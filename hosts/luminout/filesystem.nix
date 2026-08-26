{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "0bc23f27";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/fd668aa0-dc2b-4a70-87e4-d5e602c68dc9";
    allowDiscards = true;
  };

  boot.initrd.systemd.services."zfs-import-zroot" = {
    requires = [ "dev-mapper-cryptroot.device" ];
    after = [ "dev-mapper-cryptroot.device" ];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/45E1-8871";
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
  };
}
