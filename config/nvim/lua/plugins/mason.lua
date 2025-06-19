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
        'shfmt',
        'jsonls',
        'ts_ls',
        'lua_ls',
        'cssls',
        'tailwindcss',
        'prismals',
        'codespell',
        'shellcheck',
        'stylua',
      },
    },
  },
}

return M
