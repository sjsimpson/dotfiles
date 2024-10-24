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

    wk.add({
      {
        mode = { 'n', 'v' },
        { '<leader>[', group = 'previous' },
        { '<leader>]', group = 'next' },
        { '<leader>b', group = 'buffer' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'document' },
        { '<leader>e', group = 'explorer' },
        { '<leader>g', group = 'git' },
        { '<leader>gh', group = 'hunks' },
        { '<leader>h', group = 'harpoon' },
        { '<leader>l', group = 'lsp' },
        { '<leader>n', group = 'neo-tree' },
        { '<leader>q', group = 'quit/session' },
        { '<leader>s', group = 'search' },
        { '<leader>t', group = 'tabs' },
        { '<leader>w', group = 'windows' },
        { '<leader>x', group = 'diagnostics/quickfix' },
        { 'g', group = 'goto' },
        { 'gz', group = 'surround' },
      },
    })
  end,
}

return M
