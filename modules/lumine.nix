{ self, inputs, ... }:
{
  flake.nixosModules.lumine = {
    imports =
      with self.nixosModules;
      [
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default

        apps
        audio
        backups
        bluetooth
        fonts
        git
        initrd-ssh
        media
        nix
        nvim
        security
        shell
        starship
        system
        user
      ]
      ++ builtins.attrValues self.services
      ++ builtins.attrValues self.desktop
      ++ builtins.attrValues self.gaming;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
