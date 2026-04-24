{
  config,
  lib,
  vpnDomain,
  ...
}:

let
  cfg = config.lumine.network.ssh;
  userName = config.lumine.user.name;
in
{
  options.lumine.network.ssh.enable = lib.mkEnableOption "ssh config";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            identitiesOnly = true;
            identityFile = [ ];
            extraOptions = {
              PubkeyAuthentication = "no";
            };
          };

          "*.${vpnDomain} luminadel luminix luminode" = {
            identitiesOnly = true;
            identityFile = "~/.ssh/id_ed25519";
            extraOptions = {
              PubkeyAuthentication = "yes";
            };
          };

          "github.com" = {
            hostname = "github.com";
            user = "git";
            identitiesOnly = true;
            identityFile = "~/.ssh/id_ed25519";
            extraOptions = {
              PubkeyAuthentication = "yes";
            };
          };
        };
      };
    };
  };
}
