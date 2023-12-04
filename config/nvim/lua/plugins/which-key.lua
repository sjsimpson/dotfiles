local M = {
  -- Displays helpful guides to keymaps as pressed
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    plugins = { spelling = true },
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)

    local keymaps = {
      mode = { 'n', 'v' },
      ['g'] = { name = '+goto' },
      ['gz'] = { name = '+surround' },
      ['<leader>b'] = { name = '+buffer' },
      ['<leader>c'] = { name = '+code' },
      ['<leader>e'] = { name = '+explorer' },
      ['<leader>g'] = { name = '+git' },
      ['<leader>gh'] = { name = '+hunks' },
      ['<leader>h'] = { name = '+harpoon' },
      ['<leader>l'] = { name = '+lsp' },
      ['<leader>n'] = { name = '+neo-tree' },
      ['<leader>q'] = { name = '+quit/session' },
      ['<leader>s'] = { name = '+search' },
      ['<leader>t'] = { name = '+tabs' },
      -- ["<leader>u"] = { name = "+ui" },
      ['<leader>w'] = { name = '+windows' },
      ['<leader>x'] = { name = '+diagnostics/quickfix' },
    }

    wk.register(keymaps)
  end,
}

return M
