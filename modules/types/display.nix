{ lib }:

lib.types.submodule {
  options = {
    output = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };

    mode = lib.mkOption {
      type = lib.types.str;
      default = "preferred";
    };

    position = lib.mkOption {
      type = lib.types.str;
      default = "auto";
    };

    scale = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
    };

    bitdepth = lib.mkOption {
      type = lib.types.enum [
        8
        10
      ];
      default = 8;
    };

    transform = lib.mkOption {
      type = lib.types.ints.between 0 7;
      default = 0;
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "path to the wallpaper";
    };
  };
}
