local M = {
  'tpope/vim-fugitive',
  event = 'VeryLazy',
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Show git in fugitive' },
  },
}

return M
