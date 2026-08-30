{ self, ... }:
{
  flake.nixosModules.security = { config, lib, ... }: {
    options.lumine.security = {
      auth = lib.mkOption {
        type = lib.types.attrsOf (self.types.securityKey { inherit lib; });
        default = { };
        description = "authentication keys mapping (e.g. primary, backup)";
      };

      encryption = lib.mkOption {
        type = lib.types.attrsOf (self.types.securityKey { inherit lib; });
        default = { };
        description = "encryption keys mapping";
      };

      git.allowedSigners = lib.mkOption {
        type = lib.types.listOf (self.types.gitSigner { inherit lib; });
        default = [ ];
        description = "list of allowed git signers";
      };
    };

    config = lib.mkIf config.lumine.system.enable {
      users.users.${config.lumine.user.name}.openssh.authorizedKeys.keys = lib.mapAttrsToList (
        _name: key: key.pub
      ) config.lumine.security.auth;
    };
  };
}
