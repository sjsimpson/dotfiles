vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, prefix = '●' },
  severity_sort = true,
})

for name, icon in pairs(require('config.icons').diagnostics) do
  name = 'DiagnosticSign' .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
end
