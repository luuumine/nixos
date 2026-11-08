{ lib }:

lib.types.submodule {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      example = "enp1s0";
      description = "the interface name";
    };
    MACAddress = lib.mkOption {
      type = lib.types.str;
      example = "AA:BB:CC:DD:EE:FF";
      description = "the interface mac address";
    };
  };
}
