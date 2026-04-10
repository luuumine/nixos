{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.system;
in
{
  options.lumine.system = {
    enable = lib.mkEnableOption "core system config";

    hostname = lib.mkOption {
      type = lib.types.str;
    };

    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
      description = "root user shell";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
    };

    keymap = lib.mkOption {
      type = lib.types.str;
      default = "us";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Paris";
    };

    gpuBrand = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "intel"
        "nvidia"
        "none"
      ];
      default = "none";
      description = "gpu manufacturer for hardware acceleration";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostname != null && cfg.hostname != "";
        message = "lumine.system.hostname must be set";
      }
    ];

    users.defaultUserShell = cfg.shell;

    networking.hostName = cfg.hostname;
    i18n.defaultLocale = cfg.locale;
    console.keyMap = cfg.keymap;
    time.timeZone = cfg.timezone;

    environment.systemPackages = [
      pkgs.bind
      pkgs.curl
      pkgs.file
      pkgs.git
      pkgs.lm_sensors
      pkgs.unzip
      pkgs.usbutils
      pkgs.vim
      pkgs.zip
    ]
    ++ [ cfg.shell ];

    security.sudo.wheelNeedsPassword = true;

    networking.networkmanager.enable = lib.mkDefault true;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
      consoleMode = "max";
      memtest86.enable = true;
    };

    boot.loader.timeout = lib.mkDefault 5;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    system.stateVersion = "25.11";
  };

}
