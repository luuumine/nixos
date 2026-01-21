local set = vim.keymap.set

-- Native nvim
set("n", "<leader>pv", vim.cmd.Ex)

-- Global Diagnostics (Shortened)
set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Line error" })
set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev error" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Next error" })

-- Telescope
local status, telescope = pcall(require, "telescope.builtin")
if status then
  set("n", "<leader>pf", telescope.find_files, { desc = "Find Files" })
  set("n", "<C-p>", telescope.git_files, { desc = "Git Files" })
  set("n", "<leader>ps", function()
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

-- LSPs
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    local opts = { buffer = event.buf }

    set("n", "gd", vim.lsp.buf.definition, opts)
    set("n", "K", vim.lsp.buf.hover, opts)
    set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    set("n", "<leader>f", vim.lsp.buf.format, opts)
  end,
})

