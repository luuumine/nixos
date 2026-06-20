{ config, lib, ... }:

let
  cfg = config.lumine.initrd-ssh;

  authPubKeys = lib.mapAttrsToList (name: key: key.pub) config.lumine.security.auth;
in
{
  options.lumine.initrd-ssh = {
    enable = lib.mkEnableOption "initrd ssh for remote luks unlock";

    port = lib.mkOption {
      type = lib.types.port;
      default = 49152;
      description = "the port used by the ssh server in initrd";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = authPubKeys;
      description = "ssh public keys allowed to connect";
    };

    networkDrivers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "kernel modules required for the network card in initrd";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "ip=::::${config.networking.hostName}::dhcp" ];
    boot.initrd = {
      systemd.enable = true;
      systemd.network.enable = true;

      availableKernelModules = cfg.networkDrivers;

      network = {
        enable = true;
        flushBeforeStage2 = true;
        ssh = {
          enable = true;
          port = cfg.port;
          authorizedKeys = cfg.authorizedKeys;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
      };
      systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
    };
  };
}
