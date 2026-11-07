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
    };

    shell.enable = true;
    starship = {
      enable = true;
      theme = {
        username = "bold #A6E3A1";
        symbol = "bold #4A051C";
        hostname = "bold #A6E3A1";
        directory = "bold red";
      };
    };
    git.enable = true;
    nvim.enable = true;
  };
}
