{ config, vpnSecretsDir, ... }:

{
  age.secrets.wg-mullvad.file = "${vpnSecretsDir}/wg-mullvad.age";

  networking.wg-quick.interfaces.mullvad = {
    address = [
      "10.71.142.112/32"
      "fc00:bbbb:bbbb:bb01::8:8e6f/128"
    ];
    dns = [ "10.64.0.1" ];
    mtu = 1280;

    privateKeyFile = config.age.secrets.wg-mullvad.path;

    peers = [
      {
        # Amsterdam (nl-ams-wg-001)
        publicKey = "UrQiI9ISdPPzd4ARw1NHOPKKvKvxUhjwRjaI0JpJFgM=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "193.32.249.66:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
