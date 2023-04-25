local M = {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  version = '*',
  dependencies = {
    -- 'ThePrimeagen/harpoon',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { '<leader>?', '<cmd>Telescope oldfiles<cr>', desc = '[?] Find recently opened files' },
    { '<leader><space>', '<cmd>Telescope buffers<cr>', desc = '[ ] Find existing buffers' },
    -- { '<leader>/', function()
    --   -- You can pass additional configuration to telescope to change theme, layout, etc.
    --   require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    --     winblend = 10,
    --     previewer = false,
    --   })
    -- end, { desc = '[/] Fuzzily search in current buffer' } },
    { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = '[S]earch [F]iles' },
    { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = '[S]earch [H]elp' },
    { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = '[S]earch current [W]ord' },
    { '<leader>sg', '<cmd>Telescope live_grep<cr>', desc = '[S]earch by [G]rep' },
    { '<leader>sd', '<cmd>Telescope diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
    -- { '<leader>fb', require('telescope').extensions.file_browser.file_browser,
    --   { desc = '[F]ile [B]rowser', noremap = true } }
  },
  opts = {
    defaults = {
      -- Default from Kickstart.nvim
      file_ignore_patterns = { '.git/', 'docs/' },
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
        },
      },
    },
    extensions = {
      file_browser = {
        theme = 'ivy',
      },
    },
    pickers = {
      -- find_files = {
      --   hidden = true,
      -- },
      live_grep = {
        find_command = { 'rg', '!**/.git/*' },
      },
    },
  },
  config = function(_, opts)
    local telescope = require('telescope')
    telescope.setup(opts)
    pcall(require('telescope').load_extension, 'fzf')
    -- require('harpoon').setup({})
  end,
}

return M
