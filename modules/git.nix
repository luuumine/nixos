{ config, lib, ... }:

let
  cfg = config.lumine.programs.git;
  userName = config.lumine.user.name;
in
{
  options.lumine.programs.git = {
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
    home-manager.users.${userName} = {
      programs.git = {
        enable = true;

        signing = {
          format = "ssh";
          key = lib.mkDefault "~/.ssh/id_ed25519.pub";
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

      home.file.".config/git/allowed_signers".text = ''
        romain@delhommais.com	ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX	lumine@luminix
      '';
    };
  };
}
