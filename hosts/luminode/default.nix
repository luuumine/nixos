{ self, inputs, ... }: {
  flake.nixosConfigurations.luminode = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      luminode-hardware
      luminode-filesystems
      luminode-config
      luminode-backups
    ];
  };
}
