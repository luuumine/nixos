{ config, pkgs, ... }:

{
  age.secrets.wg-home.file = ../../secrets/wg-home.age;

  networking.wg-quick.interfaces = {
    home = {
      address = [ "10.0.0.4/32" ];

      dns = [ "10.0.0.1" ];

      privateKeyFile = config.age.secrets.wg-home.path;

      peers = [
        {
          publicKey = "966PZhJ0mDSsOkMoTrVNe7XTVQaBjVCI96+AceRPAmQ=";
          allowedIPs = [ "10.0.0.0/24" ];
          endpoint = "vpn.delhommais.com:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}

