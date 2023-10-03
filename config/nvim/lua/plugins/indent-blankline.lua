local M = {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    indent = {
      char = '▏',
      -- char = "│",
    },
    exclude = {
      filetypes = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy' },
    },
    scope = {
      char = '▏',
      -- char = "│",
      enabled = false,
    },
  },
}

return M
