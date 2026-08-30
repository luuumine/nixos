{ self, inputs, ... }: {
  flake.nixosConfigurations.luminova = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lumine
      common-config

      luminova-config
    ];
  };
}
