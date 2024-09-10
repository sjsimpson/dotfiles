local M = {
  -- adding highlighting to TODO comments
  'folke/todo-comments.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  cmd = { 'TodoTrouble', 'TodoTelescope' },
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next todo comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous todo comment',
    },
    { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
  },
  config = function()
    require('todo-comments').setup({})
  end,
}

return M
