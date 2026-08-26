let
  loginServer = "headscale.luuumine.com";
  vpnDomain = "vpn.luuumine.com";
in
{
  imports = [
    ./ssh.nix
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
