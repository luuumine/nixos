{
  description = "Lumine's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        luminix = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/luminix/configuration.nix ];
        };
      };
    };
}
