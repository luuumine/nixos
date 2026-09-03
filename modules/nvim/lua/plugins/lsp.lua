return {
	"neovim/nvim-lspconfig",
	config = function()
		-- Diagnostics UI
		vim.diagnostic.config({
			severity_sort = true,
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

		-- Load LSP configuration
		require("plugins.lsp.astro")
		require("plugins.lsp.c")
		require("plugins.lsp.css")
		require("plugins.lsp.json")
		require("plugins.lsp.lua")
		require("plugins.lsp.markdown")
		require("plugins.lsp.nix")
		require("plugins.lsp.python")
		require("plugins.lsp.qml")
		require("plugins.lsp.rust")
		require("plugins.lsp.typescript")
	end,
}
