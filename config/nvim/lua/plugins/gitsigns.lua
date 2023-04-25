-- git signs
local M = {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = function()
    local signs = require('config.init').icons.git
    return {
      signs = signs,
    }
  end,
}

return M
