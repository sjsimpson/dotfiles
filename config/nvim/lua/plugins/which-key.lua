local M = {
  -- Displays helpful guides to keymaps as pressed
  'folke/which-key.nvim',
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true }
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)

    local keymaps = {
      mode = { 'n' },
      ["<leader>t"] = { name = "+tabs" },
      -- ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>e"] = { name = "+explorer" },
      -- ["<leader>g"] = { name = "+git" },
      -- ["<leader>gh"] = { name = "+hunks" },
      ["<leader>q"] = { name = "+quit/session" },
      ["<leader>s"] = { name = "+search" },
      -- ["<leader>u"] = { name = "+ui" },
      ["<leader>w"] = { name = "+windows" },
      ["<leader>x"] = { name = "+diagnostics/quickfix" },
    }

    wk.register(keymaps)
  end
}

return M
