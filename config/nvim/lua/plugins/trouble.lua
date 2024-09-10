local M = {
  -- Advanced error display
  'folke/trouble.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  cmd = { 'TroubleToggle', 'Trouble' },
  opts = { use_diagnostic_signs = true },
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
    { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
    { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
    { '<leader>xQ', '<cmd>Trouble quickfix toggle<cr>', desc = 'Quickfix List (Trouble)' },
    { '<leader>xt', '<cmd>Trouble todo focus=true<cr>', desc = 'Todo (Trouble)' },
  },
  config = function(_, opts)
    require('trouble').setup(opts)
    vim.diagnostic.config()
  end,
}

return M
