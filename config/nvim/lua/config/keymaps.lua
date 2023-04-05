-- [[ Basic Keymaps ]]

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Bind escape to a
vim.keymap.set('i', 'jk', '<ESC>', { silent = true })

-- Tab
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = "New tab" })
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = "Close tab" })

-- Window
vim.keymap.set('n', '<leader>w-', '<C-W>s', { desc = "Split window horizontally"})
vim.keymap.set('n', '<leader>w|', '<C-W>v', { desc = "Split window vertically"})

-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = "Quit all" })
