{ self, inputs, ... }: {
  flake.nixosConfigurations.luminode = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      secretsPath = ../../secrets;
    };
    modules = with self.nixosModules; [
      luminode-hardware
      luminode-filesystems
      luminode-config
      luminode-backups

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
