{
  flake.services.network =
    { config, lib, ... }:
    let
      cfg = config.lumine.network;
    in
    {
      options.lumine.network = {
        vpnDomain = lib.mkOption {
          type = lib.types.str;
          default = "vpn.luuumine.com";
          description = "base domain for the internal vpn";
        };
        loginServer = lib.mkOption {
          type = lib.types.str;
          default = "headscale.luuumine.com";
          description = "headscale control server address";
        };
      };

      config = {
        _module.args = {
          inherit (cfg) vpnDomain loginServer;
        };
      };
    };
}
