{ config, lib, ... }:

let
  cfg = config.lumine.services.monero.xmrig;
in
{
  options.lumine.services.monero.xmrig = {
    enable = lib.mkEnableOption "xmrig monero miner";

    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "monero subaddress to mine to";
    };

    workerName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "worker name to display on the pool dashboard";
    };

    pools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "pool.supportxmr.com:3333" ];
      description = "list of mining pool urls (used in order as failovers)";
    };

    threads = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      description = "number of cpu threads to allocate to mining (needs 2mb l3 cache per thread)";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.address != null;
        message = "You must set lumine.services.monero.xmrig.address to a valid Monero address.";
      }
      {
        assertion = cfg.threads != null;
        message = "You must set lumine.services.monero.xmrig.threads to allocate CPU threads for mining.";
      }
    ];

    services.xmrig = {
      enable = true;
      settings = {
        autosave = false;

        cpu = lib.mkIf (cfg.threads != null) {
          rx = lib.range 0 (cfg.threads - 1);
        };

        opencl = false;
        cuda = false;

        pools = map (url: {
          inherit url;
          user = cfg.address;
          pass = cfg.workerName;
          keepalive = true;
          tls = true;
        }) cfg.pools;
      };
    };
  };
}
