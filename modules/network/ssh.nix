{
  config,
  lib,
  vpnDomain,
  ...
}:

let
  cfg = config.lumine.network.ssh;
  userName = config.lumine.user.name;

  authIdentityFiles = lib.mapAttrsToList (name: key: key.path) config.lumine.security.auth;
in
{
  options.lumine.network.ssh.enable = lib.mkEnableOption "ssh config";

  config = lib.mkIf cfg.enable {
    programs.ssh.startAgent = true;
    home-manager.users.${userName} = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "*" = {
            identitiesOnly = true;
            identityFile = [ ];
            PubkeyAuthentication = "no";
          };

          "*.${vpnDomain} luminadel luminix luminode" = {
            identitiesOnly = true;
            identityFile = authIdentityFiles;
            PubkeyAuthentication = "yes";
            ForwardAgent = "yes";
            AddKeysToAgent = "yes";
          };

          "git.luuumine.com" = {
            hostname = "luminadel";
            user = "forgejo";
            port = 3146;
            identitiesOnly = false;
            identityFile = authIdentityFiles;
            PubkeyAuthentication = "yes";
          };

          "github.com" = {
            hostname = "github.com";
            user = "git";
            identitiesOnly = false;
            identityFile = authIdentityFiles;
            PubkeyAuthentication = "yes";
          };
        };
      };
    };
  };
}
