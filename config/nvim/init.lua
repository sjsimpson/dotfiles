require("config")

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
-- small reminder here that ".." in Lua syntax concatenates 2 strings
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        { import = 'plugins' },
    },
    -- install = { missing = true, colorscheme = { 'tokyonight' } },
    -- checker = { enabled = true },
    change_detection = {
        enabled = false,
        notify = false,
    },
})
