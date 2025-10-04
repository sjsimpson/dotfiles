local M = {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    config = function()
      require('mason').setup({})
    end,
  },
  {
    -- install LSP servers
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'astro',
        'bashls',
        'cspell',
        'cssls',
        'jsonls',
        'lua_ls',
        'prismals',
        'tailwindcss',
        'ts_ls',
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      require('mason').setup()
      require('mason-lspconfig').setup(opts)
    end,
  },
  {
    -- install linters and formatters
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'cspell',
        'eslint_d',
        'prettier',
        'shellcheck',
        'shfmt',
        'stylua',
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}

return M
