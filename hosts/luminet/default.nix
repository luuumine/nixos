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
