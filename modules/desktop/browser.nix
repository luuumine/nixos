{ config, lib, ... }:

let
  cfg = config.lumine.desktop.browser;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.browser.enable = lib.mkEnableOption "browser";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.firefox = {
        enable = true;
        configPath = "${config.home-manager.users.${userName}.xdg.configHome}/mozilla/firefox";

        profiles.${userName} = {

          settings = {
            "dom.security.https_only_mode" = false;

            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.default.sites" = "";
            "extensions.pocket.enabled" = false;

            # Telemetry
            "datareporting.healthreport.uploadEnabled" = false;
            "toolkit.telemetry.enabled" = false;
            "browser.ping-centre.telemetry" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "app.shield.optoutstudies.enabled" = false;

            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
            "browser.theme.content-theme" = 0;
            "browser.theme.toolbar-theme" = 0;

            "sidebar.verticalTabs" = true;
          };
        };
      };

      xdg.mimeApps.defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };
}
