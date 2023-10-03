local M = {
  'tpope/vim-fugitive',
  event = 'VeryLazy',
  keys = {
    { '<leader>go', '<cmd>Git<cr>', desc = 'Open git in fugitive' },
  },
}

return M
