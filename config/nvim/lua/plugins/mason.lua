local M = {
  {
    -- mason lsp-config plugin
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      automatic_installation = true,
      automatic_enable = false,
    },
    config = function(_, opts)
      require('mason').setup()
      require('mason-lspconfig').setup(opts)
    end,
  },
  {
    -- install linters and formatters
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    opts = {
      ensure_installed = {
        'astro',
        'bashls',
        'cspell_ls',
        'shfmt',
        'jsonls',
        'ts_ls',
        'lua_ls',
        'cssls',
        'tailwindcss',
        'prismals',
        'codespell',
        -- 'shopify_theme_ls',
        'shellcheck',
        'stylua',
      },
    },
  },
}

return M
