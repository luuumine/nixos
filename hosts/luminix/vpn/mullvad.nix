{ config, vpnSecretsDir, ... }:

{
  age.secrets.wg-mullvad.file = "${vpnSecretsDir}/wg-mullvad.age";

  networking.wg-quick.interfaces.mullvad = {
    address = [
      "10.71.142.112/32"
      "fc00:bbbb:bbbb:bb01::8:8e6f/128"
    ];

    privateKeyFile = config.age.secrets.wg-mullvad.path;

    peers = [
      {
        # Paris (fr-par-wg-001)
        publicKey = "ov323GyDOEHLT0sNRUUPYiE3BkvFDjpmi1a4fzv49hE=";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "193.32.126.66:37021";
        persistentKeepalive = 25;
      }
    ];
  };
}

