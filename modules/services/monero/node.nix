{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.monero.node;
in
{
  options.lumine.services.monero.node = {
    enable = lib.mkEnableOption "monero full node";

    prune = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to prune the node to save space";
    };

    mining = {
      enable = lib.mkEnableOption "solo mining";

      address = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "monero address where to send mining rewards";
      };

      threads = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 0;
        description = "number of threads used for mining (0 uses all available)";
      };
    };

    rpc = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "ip address the rpc server will bind to";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 18081;
        description = "port the rpc server will bind to";
      };

      restricted = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to restrict rpc to view only commands";
      };
    };

    limits = {
      upload = lib.mkOption {
        type = lib.types.int;
        default = 10000;
        description = "limit of the upload rate in kb/s (-1 is unlimited)";
      };

      download = lib.mkOption {
        type = lib.types.int;
        default = 10000;
        description = "limit of the download rate in kb/s (-1 is unlimited)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.monero-cli ];

    services.monero = {
      enable = true;
      prune = cfg.prune;

      mining = {
        enable = cfg.mining.enable;
        address = cfg.mining.address;
        threads = cfg.mining.threads;
      };

      limits = {
        upload = cfg.limits.upload;
        download = cfg.limits.download;
      };

      rpc = {
        address = cfg.rpc.address;
        port = cfg.rpc.port;
        restricted = cfg.rpc.restricted;
      };

      # The daemon strictly requires this flag when binding RPC to a non-localhost IP
      extraConfig = lib.optionalString (cfg.rpc.address != "127.0.0.1") ''
        confirm-external-bind=1
      '';
    };
  };
}
