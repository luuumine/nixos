{ ... }:

let
  loginServer = "headscale.luuumine.com";
  vpnDomain = "vpn.luuumine.com";
in
{
  imports = [
    ./caddy.nix
    ./headscale.nix
    ./tailscale.nix
    ./mullvad.nix
  ];

  _module.args = {
    inherit loginServer;
    inherit vpnDomain;
  };
}
