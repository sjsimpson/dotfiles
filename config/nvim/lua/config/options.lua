-- Options

-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Auto write
vim.opt.autowrite = true
vim.opt.confirm = true

-- Set highlight current line
vim.opt.cursorline = true

-- Set highlight on search
vim.o.incsearch = true
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Relative Number
vim.opt.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time [for swapfile]
-- vim.opt.updatetime = 250
-- vim.opt.timeout = true
-- vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- Tabs
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true -- Insert indents automatically

-- Swap/Backup Files
vim.opt.swapfile = false
vim.opt.backup = false

-- Enables and configures undofile
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

-- this needs to be set here (not in keymaps) otherwise we can't use our <leader> key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
