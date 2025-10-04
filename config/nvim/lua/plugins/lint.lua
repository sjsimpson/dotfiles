return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      javascript = { 'eslint_d', 'cspell' },
      typescript = { 'eslint_d', 'cspell' },
      javascriptreact = { 'eslint_d', 'cspell' },
      typescriptreact = { 'eslint_d', 'cspell' },
      astro = { 'cspell' },
      sh = { 'shellcheck' },
      markdown = { 'cspell' },
      text = { 'cspell' },
    }

    -- Configure cspell to use global config
    lint.linters.cspell.args = {
      'lint',
      '--no-progress',
      '--no-summary',
      '--config',
      vim.fn.expand('~/.cspell.json'), -- ✅ Use global config
      'stdin',
    }

    -- Fast linters (eslint_d, shellcheck, etc.) on InsertLeave
    vim.api.nvim_create_autocmd('InsertLeave', {
      callback = function()
        local linters = lint.linters_by_ft[vim.bo.filetype] or {}
        -- Filter out cspell (it's slow)
        local fast = vim.tbl_filter(function(linter)
          return linter ~= 'cspell'
        end, linters)
        if #fast > 0 then
          lint.try_lint(fast)
        end
      end,
    })

    -- Slow linters only on save
    vim.api.nvim_create_autocmd('BufWritePost', {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
