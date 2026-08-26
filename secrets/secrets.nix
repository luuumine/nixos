let
  enc = import ../modules/security/keys/encryption.nix;
  hosts = import ../modules/security/keys/hosts.nix;

  users = [ enc.admin.pub ];

  inherit (hosts) luminadel;
in
{
  "luminadel/caddy.age".publicKeys = users ++ [ luminadel ];
  "luminadel/mullvad.age".publicKeys = users ++ [ luminadel ];
  "luminadel/api-lumine.age".publicKeys = users ++ [ luminadel ];

  "luminadel/headscale_api_key.age".publicKeys = users ++ [ luminadel ];
  "luminadel/headplane_cookie.age".publicKeys = users ++ [ luminadel ];

  "luminadel/forgejo-runner-token.age".publicKeys = users ++ [ luminadel ];
  "luminadel/forgejo-signing-key.age".publicKeys = users ++ [ luminadel ];

  "luminadel/wealthfolio-key.age".publicKeys = users ++ [ luminadel ];

  "luminadel/killer-game.env.age".publicKeys = users ++ [ luminadel ];
}
