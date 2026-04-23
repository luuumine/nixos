{
  description = "Lumine's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
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
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        luminix = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/luminix/default.nix
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

        luminova = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/luminova/default.nix
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
        luminadel = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            secretsPath = ./secrets;
          };
          modules = [
            ./hosts/luminadel/default.nix
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
      };

      devShells.${system}.quickshell = pkgs.mkShell {
        buildInputs = with pkgs; [
          quickshell
          kdePackages.qtdeclarative
        ];

        shellHook = ''
          echo "Quickshell Development Environment Active"
          export QML2_IMPORT_PATH="${pkgs.quickshell}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml:$QML2_IMPORT_PATH"
          export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
        '';
      };
    };
}
