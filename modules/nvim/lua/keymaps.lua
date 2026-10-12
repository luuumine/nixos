local set = vim.keymap.set

-- Native nvim
set("n", "<leader>pv", vim.cmd.Ex)
set("n", "<leader>l", "<cmd>Layout<cr>", { desc = "dev layout" })

set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Global Diagnostics (Shortened)
set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev error" })
set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next error" })

-- Telescope
local status, telescope = pcall(require, "telescope.builtin")
if status then
	set("n", "<leader>pf", telescope.git_files, { desc = "Git Files" })
	set("n", "<leader>ps", telescope.live_grep, { desc = "Grep search" })
end

-- Undotree
set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

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
	end,
})
