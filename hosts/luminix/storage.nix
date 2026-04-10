{ ... }:

{
  fileSystems = {
    "/".options = [
      "subvol=@root"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/nix".options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/home".options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/var/log".options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/var/cache".options = [
      "subvol=@cache"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/data".options = [
      "subvol=@data"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/data/media".options = [
      "subvol=@media"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/data/backups".options = [
      "subvol=@backups"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];

    "/games".options = [
      "subvol=@games"
      "noatime"
      "nodatacow"
    ];

    "/data/torrents".options = [
      "subvol=@torrents"
      "noatime"
      "nodatacow"
    ];
  };

  boot.initrd.secrets."/root/keys/data.key" = /root/keys/data.key;
  boot.initrd.luks.devices.cryptdata.keyFile = "/root/keys/data.key";

  boot.initrd.luks.devices.cryptroot.allowDiscards = true;
  boot.initrd.luks.devices.cryptdata.allowDiscards = true;
}
