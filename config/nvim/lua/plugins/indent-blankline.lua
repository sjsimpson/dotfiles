local M = {
  'lukas-reineke/indent-blankline.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = function()
    -- vim.opt.list = true
    -- vim.opt.listchars:append('space:⋅')
    return {
      char = '▏',
      context_char = '▏',
      -- space_char_blankline = ' ',
      -- char = "│",
      filetype_exclude = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy' },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    }
  end,
}

return M
