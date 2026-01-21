-- Python
local has_pyright = vim.fn.executable("pyright") == 1
if has_pyright then
  vim.lsp.config("pyright", {})
  vim.lsp.enable("pyright")
end

-- Rust
local has_rust_analyzer = vim.fn.executable("rust-analyzer") == 1
if has_rust_analyzer then
  vim.lsp.config("rust_analyzer", {})
  vim.lsp.enable("rust_analyzer")
end

-- Nix
local has_nixd = vim.fn.executable("nixd") == 1
if has_nixd then
  vim.lsp.config("nixd", {})
  vim.lsp.enable("nixd")
end

-- Lua
local has_lua_ls = vim.fn.executable("lua-language-server") == 1
if has_lua_ls then
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = { vim.env.VIMRUNTIME },
          scanExternalLibraries = false,
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  })
  vim.lsp.enable("lua_ls")
end

-- Diagnostics UI
vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
})
