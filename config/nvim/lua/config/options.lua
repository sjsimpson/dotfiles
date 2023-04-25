-- Set <space> as the leader key
-- Options

-- [[ Setting options ]]
-- See `:help vim.o`

-- Auto write
vim.opt.autowrite = true
vim.opt.confirm = true

-- Set highlight current line
vim.opt.cursorline = true

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

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

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Relative Number
vim.opt.relativenumber = true

-- Tabs
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

-- See `:help mapleader`
--
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- this needs to be set here (not in keymaps) otherwise we can't use our <leader> key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
