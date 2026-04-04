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
  };

  config = {
    assertions = [
      {
        assertion = cfg.hostname != null && cfg.hostname != "";
        message = "lumine.system.hostname must be set";
      }
    ];

    networking.hostName = cfg.hostname;
    i18n.defaultLocale = cfg.locale;
    console.keyMap = cfg.keymap;
    time.timeZone = cfg.timezone;

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

  };

}
