{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    # History settings
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      share = true;
      findNoDups = true;
      ignoreAllDups = true;
    };

    # Plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases
    shellAliases = {
      lsa = "ls -a";
      lsl = "ls -lah";
    };

    initContent = ''
      # Basic Zsh behaviors
      setopt autocd
      setopt correct

      # Binds
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H'      backward-kill-word
      bindkey '^ '      autosuggest-accept
    '';
  };
}

