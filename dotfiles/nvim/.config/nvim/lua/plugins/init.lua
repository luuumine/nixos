return {
	-- Catppuccin theme
	{
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
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
	},

	-- Treesitter
	{
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
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Tools
	{ "lewis6991/gitsigns.nvim", config = true },
	{ "mbbill/undotree" },
	{ "nvim-lualine/lualine.nvim", config = true },

	-- Formatting
	{
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
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},
	-- LSPs
	{ "neovim/nvim-lspconfig" },
}
