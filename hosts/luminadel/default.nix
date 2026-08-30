{ self, inputs, ... }: {
  flake.nixosConfigurations.luminadel = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lumine
      common-config

      luminadel-hardware
      luminadel-filesystems
      luminadel-config
      luminadel-backups
    ];
  };
}
