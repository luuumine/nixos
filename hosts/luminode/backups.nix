{
  flake.nixosModules.luminode-backups = {
    lumine.backups = {
      enable = true;
      isSink = true;
      zfsSinkDataset = "zroot/backups";
    };
  };
}
