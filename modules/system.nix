{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.system;
  types = import ./types { inherit lib; };
in
{
  options.lumine.system = {
    enable = lib.mkEnableOption "core system config";

    hostname = lib.mkOption {
      type = lib.types.str;
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

    gpus = lib.mkOption {
      type = lib.types.attrsOf types.gpu;
      default = { };
      description = "available gpus on the system";
    };

    displayGpu = lib.mkOption {
      type = lib.types.nullOr types.gpu;
      default = null;
      description = "the primary gpu used for desktop rendering and displays";
    };

    bootloaderTimeout = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 5;
      description = "the bootloader menu timeout";
    };

    displays = lib.mkOption {
      type = lib.types.listOf types.display;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostname != null && cfg.hostname != "";
        message = "lumine.system.hostname must be set";
      }
    ];

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    programs.nix-ld.enable = true;

    networking.hostName = cfg.hostname;
    i18n.defaultLocale = cfg.locale;
    console.keyMap = cfg.keymap;
    time.timeZone = cfg.timezone;

    security.sudo.wheelNeedsPassword = true;

    networking.networkmanager.enable = lib.mkDefault true;

    hardware.graphics.enable = cfg.gpus != { };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    environment.enableAllTerminfo = true;

    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
      consoleMode = "max";
      memtest86.enable = true;
    };

    boot.loader.timeout = lib.mkDefault cfg.bootloaderTimeout;

    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    system.stateVersion = "25.11";
  };

}
