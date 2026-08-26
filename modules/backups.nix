{ config, lib, ... }:

let
  cfg = config.lumine.backups;
in
{
  options.lumine.backups = {
    enable = lib.mkEnableOption "backup system";

    isSender = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether this node snapshots and pushes data";
    };

    isSink = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether this node accepts and stores snapshots from remote nodes";
    };

    zfsSourceDataset = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "ZROOT/backups";
      description = "the local zfs dataset that holds the data to be backed up";
    };

    zfsSinkDataset = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "zroot/backups_remote";
      description = "the zfs dataset where incoming remote snapshots are stored";
    };

    localSinkPools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "TANK/backups" ];
      description = "local pools to push snapshots to (e.g.: HDDs)";
    };

    remoteSinks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "luminode" ];
      description = "list of destinations to push snapshots to";
    };

    sinkClients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "100.64.0.0/10" ];
      description = "list of ip ranges allowed to push to this sink";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9876;
      description = "TCP port used for zrepl";
    };

    interval = lib.mkOption {
      default = { };
      description = "snapshot intervals for local and remote push jobs";
      type = lib.types.submodule {
        options = {
          local = lib.mkOption {
            type = lib.types.str;
            default = "1h";
            description = "how often to snapshot and push to local pools (e.g.: 1h, 30m)";
          };
          remote = lib.mkOption {
            type = lib.types.str;
            default = "6h";
            description = "how often to snapshot and push to remote nodes (e.g.: 1h, 30m)";
          };
        };
      };
    };

    bindMounts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "map of services paths to backup dataset paths for bind mounting";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      cleanName = pool: builtins.replaceStrings [ "/" ] [ "_" ] pool;

      localPushJobs = map (pool: {
        name = "push_local_${cleanName pool}";
        type = "push";
        connect = {
          type = "local";
          listener_name = "sink_local_${cleanName pool}";
          client_identity = config.networking.hostName;
        };
        filesystems = {
          "${cfg.zfsSourceDataset}<" = true;
        };
        snapshotting = {
          type = "periodic";
          interval = cfg.interval.local;
          prefix = "zrepl_local_";
        };
        pruning = {
          keep_sender = [
            { type = "not_replicated"; }
            {
              type = "last_n";
              count = 5;
            }
          ];
          keep_receiver = [
            {
              type = "grid";
              grid = "1x1h(keep=all) | 24x1h | 30x1d";
              regex = "^zrepl_local_.*";
            }
          ];
        };
      }) cfg.localSinkPools;

      localSinkJobs = map (pool: {
        name = "sink_local_${cleanName pool}";
        type = "sink";
        serve = {
          type = "local";
          listener_name = "sink_local_${cleanName pool}";
        };
        root_fs = pool;
        recv = {
          placeholder = {
            encryption = "inherit";
          };
        };
      }) cfg.localSinkPools;

      remotePushJobs = map (remote: {
        name = "push_remote_${remote}";
        type = "push";
        connect = {
          type = "tcp";
          address = "${remote}:${toString cfg.port}";
        };
        filesystems = {
          "${cfg.zfsSourceDataset}<" = true;
        };
        snapshotting = {
          type = "periodic";
          interval = cfg.interval.remote;
          prefix = "zrepl_remote_";
        };
        pruning = {
          keep_sender = [
            { type = "not_replicated"; }
            {
              type = "last_n";
              count = 5;
            }
          ];
          keep_receiver = [
            {
              type = "grid";
              grid = "1x1h(keep=all) | 24x1h | 14x1d";
              regex = "^zrepl_remote_.*";
            }
          ];
        };
      }) cfg.remoteSinks;

      remoteSinkJob = lib.optional cfg.isSink {
        name = "sink_tcp";
        type = "sink";
        serve = {
          type = "tcp";
          listen = ":${toString cfg.port}";
          clients = builtins.listToAttrs (
            map (ip: {
              name = ip;
              value = "*";
            }) cfg.sinkClients
          );
        };
        root_fs = cfg.zfsSinkDataset;
        recv = {
          placeholder = {
            encryption = "inherit";
          };
        };
      };

    in
    {
      assertions = [
        {
          assertion = cfg.isSender || cfg.isSink;
          message = "lumine.backups: module is enabled, but node is neither a sender nor a sink";
        }
        {
          assertion = !cfg.isSender || cfg.zfsSourceDataset != "";
          message = "lumine.backups: zfsSourceDataset must be set when isSender is true";
        }
        {
          assertion =
            !cfg.isSender || (builtins.length cfg.localSinkPools > 0 || builtins.length cfg.remoteSinks > 0);
          message = "lumine.backups: a sender must have at least one target in localSinkPools or remoteSinks";
        }
        {
          assertion = !cfg.isSink || cfg.zfsSinkDataset != "";
          message = "lumine.backups: zfsSinkDataset must be set when isSink is true";
        }
      ];

      fileSystems = lib.mkIf cfg.isSender (
        {
          "/backups" = {
            device = cfg.zfsSourceDataset;
            fsType = "zfs";
            neededForBoot = true;
          };
        }
        // lib.mapAttrs' (
          servicePath: backupPath:
          lib.nameValuePair servicePath {
            device = backupPath;
            fsType = "none";
            options = [ "bind" ];
            depends = [ "/backups" ];
          }
        ) cfg.bindMounts
      );

      services.zrepl = {
        enable = true;
        settings = {
          global.logging = [
            {
              type = "syslog";
              level = "info";
              format = "human";
            }
          ];

          jobs =
            (lib.optionals cfg.isSender localPushJobs)
            ++ (lib.optionals cfg.isSender localSinkJobs)
            ++ (lib.optionals cfg.isSender remotePushJobs)
            ++ remoteSinkJob;
        };
      };
    }
  );
}
