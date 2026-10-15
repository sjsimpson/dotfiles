local M = {
  'stevearc/conform.nvim',
  dependencies = { 'mason.nvim' },
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = { 'n', 'v' },
      desc = '[F]ormat buffer/selection',
    },
    {
      '<leader>F',
      '<cmd>ConformInfo<cr>',
      mode = 'n',
      desc = 'Conform [F]ormat Info',
    },
  },

  opts = {
    formatters_by_ft = {
      -- Shell
      sh = { 'shfmt' },
      bash = { 'shfmt' },

      -- Lua
      lua = { 'stylua' },

      -- JavaScript/TypeScript
      javascript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescript = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },

      -- Web frameworks
      vue = { 'oxfmt' },

      -- Styles
      css = { 'oxfmt' },
      scss = { 'oxfmt' },
      less = { 'oxfmt' },

      -- Markup
      markdown = { 'oxfmt' },
      ['markdown.mdx'] = { 'oxfmt' },

      -- Data
      json = { 'oxfmt' },
      jsonc = { 'oxfmt' },

      -- Other
      graphql = { 'oxfmt' },
    },

    format_on_save = function()
      -- Disable if global flag is set
      if vim.g.disable_autoformat then
        return
      end
      return {
        timeout_ms = 3000,
        lsp_fallback = true,
      }
    end,

    formatters = {
      oxfmt = {
        command = 'oxfmt',
        args = { '--stdin-filepath', '$FILENAME' },
        stdin = true,
      },
    },
  },
}

return M
