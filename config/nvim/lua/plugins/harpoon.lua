local M = {
  'ThePrimeagen/harpoon',
  keys = function()
    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')

    return {
      vim.keymap.set('n', '<leader>ha', function()
        mark.add_file()
      end, { desc = '[H]arpoon [A]dd' }),

      vim.keymap.set('n', '<leader>ht', function()
        ui.toggle_quick_menu()
      end, { desc = '[H]arpoon [T]oggle' }),

      vim.keymap.set('n', '<leader>h1', function()
        ui.nav_file(1)
      end, { desc = '[H]arpoon File 1' }),
      vim.keymap.set('n', '<leader>h2', function()
        ui.nav_file(2)
      end, { desc = '[H]arpoon File 2' }),
      vim.keymap.set('n', '<leader>h3', function()
        ui.nav_file(3)
      end, { desc = '[H]arpoon File 3' }),
      vim.keymap.set('n', '<leader>h4', function()
        ui.nav_file(4)
      end, { desc = '[H]arpoon File 4' }),

      vim.keymap.set('n', '<leader>ho', function()
        ui.nav_prev()
      end, { desc = '[H]arpoon: Previous File' }),

      vim.keymap.set('n', '<leader>hi', function()
        ui.nav_next()
      end, { desc = '[H]arpoon: Next File' }),
    }
  end,
}

return M
