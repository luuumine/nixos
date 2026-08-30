{ self, inputs, ... }: {
  flake.nixosConfigurations.luminadel = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      secretsPath = ../../secrets;
    };
    modules = with self.nixosModules; [
      luminadel-hardware
      luminadel-filesystems
      luminadel-config
      luminadel-backups

      ../../modules

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
      }
      inputs.agenix.nixosModules.default
    ];
  };
}
