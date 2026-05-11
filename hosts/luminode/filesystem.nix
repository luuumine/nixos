{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "667f583d";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/95cca963-5f92-4ad3-ba44-b00ba59af7fb";
    allowDiscards = true;
  };

  boot.initrd.systemd.services."zfs-import-zroot" = {
    requires = [ "dev-mapper-cryptroot.device" ];
    after = [ "dev-mapper-cryptroot.device" ];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/9EF2-ECB2";
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
