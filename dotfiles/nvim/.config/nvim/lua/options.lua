-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Visuals & Layout
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "88"

-- Search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false

-- System & Performance
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.mouse = ""
vim.opt.eol = true
vim.opt.fixeol = true

-- Persistent undo for undotree
vim.opt.undofile = true

-- Split Management
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Backup management
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
