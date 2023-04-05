local M = {
  --tokyo-night-theme
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    style = 'storm'
  },
  config = function(_, opts)
    local tokyonight = require('tokyonight')
    tokyonight.setup(opts)
    vim.cmd('colorscheme tokyonight')
  end,
}

return M
