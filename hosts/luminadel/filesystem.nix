{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "0c70559e";

  boot.zfs.extraPools = [ "TANK" ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/9a559a0c-72d1-4620-af33-821e635627b5";
    allowDiscards = true;
  };

  boot.initrd.systemd.services."zfs-import-ZROOT" = {
    requires = [ "dev-mapper-cryptroot.device" ];
    after = [ "dev-mapper-cryptroot.device" ];
  };

  environment.etc.crypttab.text = ''
    crypttank /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZBF4TM /root/tank.key luks
  '';
  systemd.services."zfs-import-TANK" = {
    requires = [ "systemd-cryptsetup@crypttank.service" ];
    after = [ "systemd-cryptsetup@crypttank.service" ];
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

    "/media" = {
      device = "TANK/media";
      fsType = "zfs";
    };

    "/backups" = {
      device = "TANK/backups";
      fsType = "zfs";
    };
  };
}
