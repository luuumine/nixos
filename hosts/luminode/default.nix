{ self, inputs, ... }: {
  flake.nixosConfigurations.luminode = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lumine
      common-config

      luminode-hardware
      luminode-filesystems
      luminode-config
      luminode-backups
    ];
  };
}
