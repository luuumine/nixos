{ self, inputs, ... }: {
  flake.nixosConfigurations.luminova = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      secretsPath = ../../secrets;
    };
    modules = with self.nixosModules; [
      luminova-config

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
