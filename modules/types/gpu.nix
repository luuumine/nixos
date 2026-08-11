{ lib }:

lib.types.submodule {
  options = {
    brand = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "intel"
        "nvidia"
      ];
      description = "gpu manufacturer";
    };

    path = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/dev/dri/by-path/pci-0000:03:00.0-render";
      description = "persistent path to the render device";
    };
  };
}
