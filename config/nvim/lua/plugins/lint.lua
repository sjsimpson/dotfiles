-- linting and spellcheck
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      javascript = { 'cspell' },
      typescript = { 'cspell' },
      javascriptreact = { 'cspell' },
      typescriptreact = { 'cspell' },
      astro = { 'cspell' },
      lua = { 'cspell' },
      sh = { 'shellcheck' },
      markdown = { 'cspell' },
      text = { 'cspell' },
      prisma = { 'cspell' },
      rust = { 'cspell' },

      -- Optionally add wildcard for using linters in all file types
      -- ['*'] = { 'cspell' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    -- Auto lint
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Lint info command
    vim.api.nvim_create_user_command('LintInfo', function()
      local linters = require('lint').linters_by_ft[vim.bo.filetype] or {}
      if #linters == 0 then
        vim.notify('No linters configured for filetype: ' .. vim.bo.filetype, vim.log.levels.WARN)
      else
        vim.notify('Active linters: ' .. table.concat(linters, ', '), vim.log.levels.INFO)
      end
    end, {})
  end,
}
