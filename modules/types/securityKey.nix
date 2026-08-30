{
  flake.types.securityKey =
    { lib }:
    lib.types.submodule {
      options = {
        pub = lib.mkOption {
          type = lib.types.str;
          description = "public key string";
        };
        path = lib.mkOption {
          type = lib.types.str;
          description = "path to the private key identity file";
        };
      };
    };
}
