{ ... }:

let
  loginServer = "https://headscale.luuumine.com";
  vpnDomain = "vpn.luuumine.com";
in
{
  imports = [
    ./caddy.nix
    ./headscale.nix
    ./tailscale.nix
  ];

  _module.args = {
    inherit loginServer;
    inherit vpnDomain;
  };
}
