{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  lumine = {
    initrd-ssh = {
      enable = true;
      port = 49152;
      networkDrivers = [
        "r8169"
        "igc"
      ];
    };

    user.name = "lumine";
    system = {
      enable = true;
      hostname = "luminet";
      gpus = {
        intel-igpu = {
          brand = "intel";
          path = "/dev/dri/by-path/pci-0000:00:02.0-render";
        };
      };
    };

    nix.enable = true;

    network = {
      router = {
        enable = true;
        wanInterface = {
          # I225-V, uses igc
          name = "wan";
          MACAddress = "a0:1e:0b:13:b5:bc";
        };
        lanInterface = {
          # RTL8125, uses r8169
          name = "lan";
          MACAddress = "a0:1e:0b:13:b5:bd";
        };
        lanAddress = "10.67.0.1/24";
      };
      ssh.enable = true;
      tailscale.enable = true;
    };

    shell.enable = true;
    starship = {
      enable = true;
      theme = {
        username = "bold cyan";
        symbol = "bold yellow";
        hostname = "bold cyan";
        directory = "bold blue";
      };
    };
    git.enable = true;
    nvim.enable = true;
  };
}
