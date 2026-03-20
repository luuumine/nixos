{ ... }:

{
  boot.initrd.luks.devices."cryptnova" = {
    device = "/dev/disk/by-uuid/9bb74af8-cc2f-4983-9adf-c502908751ce";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptnova";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4A1B-497C";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/shared" = {
      device = "/dev/disk/by-uuid/4951-11D9";
      fsType = "exfat";
      options = [
        "nofail"
        "uid=1000"
        "gid=100"
        "dmask=000"
        "fmask=000"
      ];
    };
  };
}
