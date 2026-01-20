{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd

    # Language Servers
    lua-language-server
    nixd
    pyright
    rust-analyzer
  ];
}

