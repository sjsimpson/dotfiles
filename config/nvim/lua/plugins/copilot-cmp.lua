local M = {
  'zbirenbaum/copilot-cmp',
  dependencies = 'zbirenbaum/copilot.lua',
  config = function()
    require('copilot_cmp').setup()
  end,
}

return M
