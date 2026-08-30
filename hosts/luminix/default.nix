{ self, inputs, ... }: {
  flake.nixosConfigurations.luminix = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lumine
      common-config

      luminix-hardware
      luminix-filesystems
      luminix-config
    ];
  };
}
