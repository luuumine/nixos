return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = {
				"c",
				"lua",
				"nix",
				"python",
				"query",
				"rust",
				"vim",
				"vimdoc",
				"javascript",
				"qml",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
