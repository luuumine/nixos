{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

      user.name = "Romain Delhommais";
      user.email = "romain@delhommais.com";

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
    romain@delhommais.com	ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIAd/DXNxI99DHBYcAZdH9OrP+B8OOZyuzmhWS8Enrfrq	lumine@luminarch
    admin@delhommais.com	ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIJRCMQsmr37LzZb34rZ+pca0AvlCDQOoUsZBZB0a3yuB	lumine@luminode
  '';
}
