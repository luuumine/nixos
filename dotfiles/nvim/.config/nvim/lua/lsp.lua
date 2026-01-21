-- Python
local has_pyright = vim.fn.executable("pyright") == 1
if has_pyright then
  vim.lsp.config("pyright", {})
  vim.lsp.enable("pyright", {})
end

-- Rust
local has_rust_analyzer = vim.fn.executable("rust-analyzer") == 1
if has_rust_analyzer then
  vim.lsp.config("rust_analyzer", {})
  vim.lsp.enable("rust_analyzer", {})
end

-- Nix
local has_nixd = vim.fn.executable("nixd") == 1
if has_nixd then
  vim.lsp.config("nixd", {})
  vim.lsp.enable("nixd", {})
end

