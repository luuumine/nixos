{ config, lib, ... }:

{
  lumine.backups = {
    enable = true;
    isSender = true;
    zfsSourceDataset = "ZROOT/backups";
    localSinkPools = [ "TANK/backups" ];
    remoteSinks = [ "luminode" ];

    interval = {
      local = "1h";
      remote = "1h";
    };

    bindMounts = {
      "/var/lib/immich" = "/backups/immich";
      "/var/lib/jellyfin" = "/backups/jellyfin";
      "/var/lib/wealthfolio" = "/backups/wealthfolio";
    };
  };
  lumine.services.git.enableBackups = true;
}
