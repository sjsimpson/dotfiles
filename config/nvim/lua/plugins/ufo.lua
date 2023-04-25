local M = {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = 'VeryLazy',
  opts = {},
  config = function()
    require('ufo').setup()
  end,
}

return M
