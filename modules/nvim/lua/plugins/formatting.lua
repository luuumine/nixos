return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				nix = { "nixfmt" },
				rust = { "rustfmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				astro = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				html = { "prettier" },
				qml = { "qmlformat" },
				c = { "clang-format" },
				markdown = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = false,
			},
		})
	end,
}
