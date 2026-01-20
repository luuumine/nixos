-- Native nvim
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Telescope
local status, telescope = pcall(require, "telescope.builtin")
if status then
  vim.keymap.set("n", "<leader>pf", function()
    telescope.find_files()
  end, { desc = "Find Files" })
  vim.keymap.set("n", "<C-p>", function()
    telescope.git_files()
  end, { desc = "Git Files" })
  vim.keymap.set("n", "<leader>ps", function()
    telescope.grep_string({ search = vim.fn.input("Grep > ") });
  end, { desc = "Grep search" })
end

-- Undotree
vim.keymap.set("n", "<leader>u", function()
  vim.cmd.UndotreeToggle()
end, { desc = "Toggle Undotree" })

-- Gitsigns
local status, gitsigns = pcall(require, "gitsigns")
if status then
  vim.keymap.set("n", "<leader>gb", function()
    gitsigns.toggle_current_line_blame()
  end, { desc = "Toggle Git Blame" })
end

