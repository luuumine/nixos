{
  flake.types.gitSigner =
    { lib }:
    lib.types.submodule {
      options = {
        email = lib.mkOption {
          type = lib.types.str;
        };
        pub = lib.mkOption {
          type = lib.types.str;
          description = "public key string";
        };
      };
    };
}
