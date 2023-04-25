local M = {
  'jose-elias-alvarez/null-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'williamboman/mason.nvim',
  },
  opts = function()
    local null_ls = require('null-ls')
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions
    -- local completion = null_ls.builtins.completion
    return {
      root_dir = require('null-ls.utils').root_pattern('stylua.toml', '.git'),
      sources = {
        formatting.stylua,
        formatting.prettier,
        -- formatting.eslint,
        formatting.fish_indent,
        -- diagnostics.eslint,
        diagnostics.fish,
        -- diagnostics.tsc,
        -- code_actions.eslint,
        code_actions.gitsigns,
      },
      debug = true,
    }
  end,
  config = function(_, opts)
    require('null-ls').setup(opts)
  end,
}

return M
