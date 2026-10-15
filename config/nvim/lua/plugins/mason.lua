local M = {
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    opts = {},
  },
  {
    -- install LSP servers
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = {
        'astro',
        'bashls',
        'cssls',
        'jsonls',
        'lua_ls',
        'prismals',
        'rust_analyzer',
        'tailwindcss',
      },
      automatic_installation = true,
    },
  },
  {
    -- install linters and formatters
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = {
        'cspell',
        'oxfmt',
        'oxlint',
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
