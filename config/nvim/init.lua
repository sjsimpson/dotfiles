require 'config.options'
require 'config.lazy'

-- lazy.nvim will call the User autocommand after lazy has loaded
vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function()
        require 'config.autocmds'
        require 'config.keymaps'
    end,
})
