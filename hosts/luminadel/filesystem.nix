{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "0c70559e";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/9a559a0c-72d1-4620-af33-821e635627b5";
    allowDiscards = true;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/0AF1-6ADB";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/" = {
      device = "ZROOT/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "ZROOT/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "ZROOT/home";
      fsType = "zfs";
    };
  };
}
