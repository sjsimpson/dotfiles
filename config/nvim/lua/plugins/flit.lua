-- easily jump to any location and enhanced f/t motions for Leap
local M = {
  'ggandor/flit.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'ggandor/leap.nvim',
  },
}

return M
