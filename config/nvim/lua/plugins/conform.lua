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
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },

      -- Web frameworks
      astro = { 'prettier' },
      vue = { 'prettier' },
      svelte = { 'prettier' },

      -- Styles
      css = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },

      -- Markup
      html = { 'prettier' },
      markdown = { 'prettier' },
      ['markdown.mdx'] = { 'prettier' },

      -- Data
      json = { 'prettier' },
      jsonc = { 'prettier' },
      yaml = { 'prettier' },

      -- Other
      graphql = { 'prettier' },
      handlebars = { 'prettier' },
    },

    format_on_save = function()
      -- Disable if global flag is set
      if vim.g.disable_autoformat then
        return
      end
      return {
        timeout_ms = 500,
        lsp_fallback = true,
      }
    end,

    formatters = {
      prettier = {
        prepend_args = function(_, ctx)
          -- Use Astro parser for .astro files
          if vim.bo[ctx.buf].filetype == 'astro' then
            return { '--parser', 'astro' }
          end
          return {}
        end,
      },
    },
  },
}

return M
