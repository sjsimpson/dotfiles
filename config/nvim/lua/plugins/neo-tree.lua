local M = {
    'nvim-neo-tree/neo-tree.nvim',
    keys = {
        {
            '<leader>nt',
            function()
                require('neo-tree.command').execute({ toggle = true, dir = vim.loop.cwd() })
            end,
            desc = '[N]eo-tree [T]oggle',
        },
        {
            '<leader>nf',
            function()
                require('neo-tree.command').execute({ dir = vim.loop.cwd() })
            end,
            desc = '[N]eo-tree [F]ocus',
        },
    },
    branch = 'v2.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
    },
    opts = {
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = true,
            filtered_items = {
                hidden_by_name = {
                    '.git/',
                    'node_modules/',
                },
            },
        },
        window = {
            mappings = {
                ['<space>'] = 'none',
            },
        },
        default_component_configs = {
            indent = {
                with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = '',
                expander_expanded = '',
                expander_highlight = 'NeoTreeExpander',
            },
        },
    },
    config = function(_, opts)
        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        require('neo-tree').setup(opts)
    end,
}

return M
