{ ... }:

{
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

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          PubkeyAuthentication = "yes";
        };
      };

      "luminode" = {
        hostname = "10.0.0.1";
        user = "lumine";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          PubkeyAuthentication = "yes";
        };
      };
    };
  };
}
