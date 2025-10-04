local M = {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle pin' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete non-pinned buffers' },
    { '<leader>[b', '<Cmd>BufferLineCyclePrev<CR>', desc = 'Move to previous buffer' },
    { '<leader>]b', '<Cmd>BufferLineCycleNext<CR>', desc = 'Move to next buffer' },
    { '<leader>bj', '<Cmd>BufferLinePick<CR>', desc = 'Jump to buffer' },
  },
  opts = {
    options = {
      diagnostics = 'nvim_lsp',
      always_show_bufferline = false,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Neo-tree',
          highlight = 'Directory',
          text_align = 'left',
        },
      },
    },
  },
}

return M
