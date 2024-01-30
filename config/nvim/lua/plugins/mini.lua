return {
    {
        'echasnovski/mini.ai',
        version = false,
        event = 'VeryLazy',
        config = function()
            require('mini.ai').setup({})
        end,
    },
    {
        'echasnovski/mini.bufremove',
        version = false,
        -- stylua: ignore
        keys = {
            { "<leader>br", function() require("mini.bufremove").delete(0, false) end, desc = "Remove Buffer" },
            { "<leader>bR", function() require("mini.bufremove").delete(0, true) end,  desc = "Remove Buffer (Force)" },
        },
    },
    {
        'echasnovski/mini.comment',
        version = '*',
        event = 'VeryLazy',
        opts = {
            hooks = {
                pre = function()
                    return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo
                    .commentstring
                end,
            },
        },
        config = function(_, opts)
            require('mini.comment').setup(opts)
        end,
    },
    {
        version = false,
        'echasnovski/mini.indentscope', -- wait till new 0.7.0 release to put it back on semver
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            symbol = '▏',
            -- symbol = "│", -- just a thicker symbol
            options = { try_as_border = true },
            filetype_exclude = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy', 'mason' },
            -- These are the default mappings, but I put them here so I could change them (awesome for HTML tags)
            mappings = {
                -- Textobjects
                object_scope = 'ii',
                object_scope_with_border = 'ai',

                -- Motions (jump to respective border line; if not present - body line)
                goto_top = '[i',
                goto_bottom = ']i',
            },
        },
        config = function(_, opts)
            local indent = require('mini.indentscope')
            local adds = {
                draw = {
                    animation = indent.gen_animation.none(),
                },
            }

            -- Merge additional options to opts table
            for k, v in pairs(adds) do
                opts[k] = v
            end

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('local_disable_mini.indentscope', { clear = true }),
                pattern = opts.filetype_exclude,
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })

            indent.setup(opts)
        end,
    },
    {
        'echasnovski/mini.pairs',
        version = false,
        event = 'VeryLazy',
        config = function()
            require('mini.pairs').setup({})
        end,
    },
    {
        'echasnovski/mini.surround',
        version = false,
        event = 'VeryLazy',
        opts = {
            mappings = {
                add = 'gza',    -- Add surrounding in Normal and Visual modes
                delete = 'gzd', -- Delete surrounding
                find = 'gzf',   -- Find surrounding (to the right)
                find_left = 'gzF', -- Find surrounding (to the left)
                highlight = 'gzh', -- Highlight surrounding
                replace = 'gzr', -- Replace surrounding
                update_n_lines = 'gzn', -- Update `n_lines`
            },
        },
        config = function(_, opts)
            require('mini.surround').setup(opts)
        end,
    },
}
