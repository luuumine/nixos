{ config, pkgs, ... }:

{
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
    '';
  };
}
