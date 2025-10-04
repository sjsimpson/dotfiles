-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

-- Bind escape to a
vim.keymap.set('i', 'jk', '<ESC>', { silent = true })

-- Tab
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })

-- Window
vim.keymap.set('n', '<leader>w-', '<C-W>s <C-W><Down>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>w|', '<C-W>v <C-W><Right>', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>wm', '<C-W><Left>', { desc = 'Switch to left window' })
vim.keymap.set('n', '<leader>wn', '<C-W><Down>', { desc = 'Switch to below window' })
vim.keymap.set('n', '<leader>we', '<C-W><Up>', { desc = 'Switch to above window' })
vim.keymap.set('n', '<leader>wi', '<C-W><Right>', { desc = 'Switch to right window' })
vim.keymap.set('n', '<leader>wd', '<cmd>q<cr>', { desc = 'Remove current window' })

-- Explorer
-- vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>', { desc = 'Open Explorer' })

-- Show current filepath
vim.keymap.set('n', '<leader>ps', '1<C-g>', { desc = 'Show current filepath' })
vim.keymap.set('n', '<leader>pc', '<cmd>let @+ = expand("%")<cr>', { desc = 'Show current filepath' })

-- Quick actions
vim.keymap.set('n', 'dp', '_hvk$di<space><esc>', { desc = 'Remove whitespace to last line' })

-- Better page jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Lazy
vim.keymap.set('n', '<leader>L', '<cmd>:Lazy<cr>', { desc = 'Lazy' })

-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })

-- Toggle format on save
vim.keymap.set('n', '<leader>tf', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  local status = vim.g.disable_autoformat and 'disabled' or 'enabled'
  vim.notify('Format on save ' .. status)
end, { desc = '[T]oggle [F]ormat on save' })

-- Quick edit global cspell config
vim.keymap.set('n', '<leader>cw', function()
  vim.cmd('vsplit ~/.cspell.json')
  vim.fn.search('"words"')
end, { desc = '[C]spell edit global [W]ords' })

-- Or even simpler - add word under cursor
vim.keymap.set('n', '<leader>ca', function()
  local word = vim.fn.expand('<cword>')
  local cspell_file = vim.fn.expand('~/.cspell.json')

  -- Simple append (assumes words array exists)
  vim.cmd('edit ' .. cspell_file)
  vim.fn.search('"words"')
  vim.fn.search(']', 'b') -- Find closing bracket
  vim.cmd('normal! O"' .. word .. '",')
  vim.cmd('write')
  vim.cmd('bdelete')

  vim.notify('Added "' .. word .. '" to global dictionary')
  require('lint').try_lint()
end, { desc = '[C]spell [A]dd word to dictionary' })

----------------------------------------

-- QWERTY Keymaps

-- Window
vim.keymap.set('n', '<leader>wh', '<C-W><Left>', { desc = 'Switch to left window' })
vim.keymap.set('n', '<leader>wj', '<C-W><Down>', { desc = 'Switch to below window' })
vim.keymap.set('n', '<leader>wk', '<C-W><Up>', { desc = 'Switch to above window' })
vim.keymap.set('n', '<leader>wl', '<C-W><Right>', { desc = 'Switch to right window' })
