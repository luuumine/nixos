{ config, lib, ... }:

let
  authKeys = import ./keys/auth.nix;
  encKeys = import ./keys/encryption.nix;
  gitKeys = import ./keys/git.nix;
  userName = config.lumine.user.name;

  keyType = lib.types.submodule {
    options = {
      pub = lib.mkOption { type = lib.types.str; };
      path = lib.mkOption { type = lib.types.str; };
    };
  };
in
{
  options.lumine.security = {
    auth = lib.mkOption {
      type = lib.types.attrsOf keyType;
      default = authKeys;
      description = "authentication keys mapping (e.g. primary, backup)";
    };

    encryption = lib.mkOption {
      type = lib.types.attrsOf keyType;
      default = encKeys;
      description = "encryption keys mapping";
    };

    git.allowedSigners = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            email = lib.mkOption { type = lib.types.str; };
            pub = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = gitKeys;
      description = "list of allowed git signers";
    };
  };

  config = lib.mkIf config.lumine.system.enable {
    # Dynamically maps over all auth keys to authorize them for SSH login
    users.users.${userName}.openssh.authorizedKeys.keys = lib.mapAttrsToList (
      name: key: key.pub
    ) config.lumine.security.auth;
  };
}
