{ ... }:

{
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/f99b46ec-1178-4ed9-a8f7-37b8b1c070bc";
    allowDiscards = true;
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
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@root"
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };

    "/nix" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };

    "/home" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };
    "/var/log" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@log"
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };

    "/var/cache" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@cache"
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };

    "/games" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@games"
        "noatime"
        "nodatacow"
      ];
    };
  };
}
