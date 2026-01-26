local set = vim.keymap.set

-- Native nvim
set("n", "<leader>pv", vim.cmd.Ex)
set("n", "<leader>v-", "<cmd>vsplit<cr>", { desc = "Vertical split" })
set("n", "<leader>h-", "<cmd>split<cr>", { desc = "Horizontal split" })
set("n", "<leader>tv", "<cmd>vsplit | terminal<cr>a", { desc = "Vertical terminal" })
set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Global Diagnostics (Shortened)
set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Line error" })
set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev error" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Next error" })

-- Telescope
local status, telescope = pcall(require, "telescope.builtin")
if status then
	set("n", "<leader>pf", telescope.find_files, { desc = "Find Files" })
	set("n", "<C-p>", telescope.git_files, { desc = "Git Files" })
	set("n", "<leader>pa", function()
		telescope.find_files({
			no_ignore = true,
			hidden = true,
			file_ignore_patterns = { ".git/" },
		})
	end, { desc = "Find All Files" })
	set("n", "<leader>ps", telescope.live_grep, { desc = "Grep search" })
	set("n", "<leader>pS", function()
		telescope.grep_string({ search = vim.fn.input("Grep > ") })
	end, { desc = "Grep search" })
end

-- Undotree
set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

-- Gitsigns
local status, gitsigns = pcall(require, "gitsigns")
if status then
	set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Git Blame" })
end

-- Formatting
set("n", "<leader>f", function()
	require("conform").format({
		lsp_format = "fallback",
		async = true,
		timeout_ms = 500,
	})
end, { desc = "Format File" })

-- LSPs
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(event)
		local opts = { buffer = event.buf }

		set("n", "gd", vim.lsp.buf.definition, opts)
		set("n", "K", vim.lsp.buf.hover, opts)
		set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
		set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
	end,
})
