local M = {
  'ThePrimeagen/harpoon',
  keys = {
    vim.keymap.set('n', '<leader>ha', function() require('harpoon.mark').add_file() end, { desc = "[H]arpoon [A]dd"}),
    vim.keymap.set('n', '<leader>ht', function() require('harpoon.ui').toggle_quick_menu() end, { desc = "[H]arpoon [T]oggle"})
  },
}

return M
