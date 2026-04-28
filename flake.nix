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

    headplane = {
      url = "github:tale/headplane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    luuumine-website = {
      url = "github:luuumine/luuumine.com";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    delhommais-website = {
      url = "git+ssh://git@github.com/luuumine/delhommais.com.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      headplane,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            secretsPath = ./secrets;
          };
          modules = [
            ./hosts/${hostName}
            ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            agenix.nixosModules.default
            headplane.nixosModules.headplane
            {
              nixpkgs.overlays = [ headplane.overlays.default ];
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        luminix = mkHost "luminix";
        luminova = mkHost "luminova";
        luminadel = mkHost "luminadel";
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
