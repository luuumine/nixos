return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
			integrations = {
				telescope = { enabled = true },
				treesitter = true,
				gitsigns = true,
				native_lsp = { enabled = true },
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
