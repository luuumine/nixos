{
  description = "Lumine's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      overlays.default = final: prev: { lumine = import ./packages { pkgs = final; }; };

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            secretsPath = ./secrets;
          };
          modules = [
            { nixpkgs.overlays = [ self.overlays.default ]; }
            ./hosts/${hostName}
            ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            agenix.nixosModules.default
          ];
        };
    in
    {
      inherit overlays;
      nixosConfigurations = {
        luminix = mkHost "luminix";
        luminova = mkHost "luminova";
        luminadel = mkHost "luminadel";
        luminout = mkHost "luminout";
        luminode = mkHost "luminode";
      };

      wallpapers = import ./wallpapers;

      packages.${system} = import ./packages {
        pkgs = nixpkgs.legacyPackages.${system};
      };
    };
}
