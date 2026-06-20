{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.git;
  userName = config.lumine.user.name;
in
{
  options.lumine.git = {
    enable = lib.mkEnableOption "git configuration";
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Romain Delhommais";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "romain@delhommais.com";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.git
      pkgs.git-lfs
    ];

    home-manager.users.${userName} = {
      programs.git = {
        enable = true;

        lfs.enable = true;

        signing = {
          format = "ssh";
          key = lib.mkDefault "${config.lumine.security.auth.primary.path}.pub";
          signByDefault = true;
        };

        settings = {
          alias = {
            sts = "status --short";
          };

          gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

          user.name = cfg.user.name;
          user.email = cfg.user.email;

          init.defaultBranch = "main";

          commit.verbose = true;

          log.date = "iso";
          column.ui = "auto";

          pull.rebase = true;
          push.autoSetupRemote = true;

          merge.conflictStyle = "zdiff3";

          rebase.autoSquash = true;
          rebase.autoStash = true;
          rebase.updateRefs = true;
          rerere.enabled = true;

          fetch.fsckObjects = true;
          receive.fsckObjects = true;
          transfer.fsckobjects = true;
        };
      };

      home.file.".config/git/allowed_signers".text = lib.concatMapStringsSep "\n" (
        k: "${k.email} ${k.pub}"
      ) config.lumine.security.git.allowedSigners;
    };
  };
}
