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
        'cssls',
        'eslint',
        'jsonls',
        'lua_ls',
        'prismals',
        'rust_analyzer',
        'tailwindcss',
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
