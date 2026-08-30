{ self, inputs, ... }: {
  flake.nixosConfigurations.luminout = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lumine
      common-config

      luminout-hardware
      luminout-filesystems
      luminout-config
    ];
  };
}
