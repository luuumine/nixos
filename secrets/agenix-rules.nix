let
  enc = import ../modules/security/keys/encryption.nix;
  hosts = import ../modules/security/keys/hosts.nix;

  users = [ enc.admin.pub ];

  hostSecrets = {
    luminadel = [
      "api-lumine.age"
      "caddy.age"
      "forgejo-runner-token.age"
      "forgejo-signing-key.age"
      "harmonia.age"
      "headplane_cookie.age"
      "killer-game.env.age"
      "mullvad.age"
      "vaultwarden.age"
      "wealthfolio-key.age"
    ];
  };

  mkHostRules =
    host: files:
    map (file: {
      name = "${host}/${file}";
      value.publicKeys = users ++ [ hosts.${host} ];
    }) files;
in
builtins.listToAttrs (
  builtins.concatLists (
    map (host: mkHostRules host hostSecrets.${host}) (builtins.attrNames hostSecrets)
  )
)
