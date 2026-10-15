# Neovim

Linked to `~/.config/nvim`. Plugins are managed by
[lazy.nvim](https://github.com/folke/lazy.nvim) (pinned in `lazy-lock.json`),
and LSPs, linters, and formatters by [Mason](https://github.com/mason-org/mason.nvim).
Everything installs on first launch.

## Layout

```
init.lua              bootstraps lazy.nvim, imports lua/plugins
lua/config/           options, keymaps, autocmds, diagnostics
lua/plugins/<name>.lua  one plugin (or small group) per file
```

To add a plugin, create `lua/plugins/<name>.lua` returning a lazy.nvim spec.

## Keys

Leader is **Space**. Press it and wait for [which-key](https://github.com/folke/which-key.nvim)
to show every binding. A few to know:

| Keys                       | What                                  |
| -------------------------- | ------------------------------------- |
| `jk` (insert)              | Escape                                |
| `<leader>f` / `<leader>F`  | Format buffer / formatter info        |
| `<leader>tf`               | Toggle format on save                 |
| `<leader>ca` / `<leader>cw` | Add word to cspell / edit cspell words |
| `<leader>w` + `h/j/k/l`    | Move between windows                  |
| `<leader>L`                | Lazy (plugin manager)                 |
| `gd`, `gr`, `K`, `<leader>rn` | LSP definition, references, hover, rename |

## Plugins

| Area        | Plugins                                                                 |
| ----------- | ----------------------------------------------------------------------- |
| UI          | tokyonight (storm), lualine, bufferline, noice + nvim-notify, dressing, indent-blankline, mini.indentscope, vim-illuminate |
| Navigation  | telescope, neo-tree, spectre (search/replace), trouble, todo-comments   |
| Editing     | mini (ai, surround, pairs, comment, bufremove), nvim-ufo (folds), vim-sleuth |
| Code        | treesitter (+ textobjects), nvim-lspconfig, blink.cmp, LuaSnip + friendly-snippets |
| Git         | gitsigns, fugitive + rhubarb, lazygit.nvim                              |
| Tooling     | mason, conform (format), nvim-lint (lint)                               |
| Filetypes   | vim-prisma, vim-kitty                                                   |

## Language tooling

| Kind       | Tools                                                     | Configured in |
| ---------- | --------------------------------------------------------- | ------------- |
| LSP        | astro, bashls, cssls, jsonls, lua_ls, prismals, rust_analyzer, tailwindcss, tsgo | `lsp.lua`, `mason.lua` |
| Formatters | oxfmt (JS/TS, CSS, JSON, Markdown, GraphQL), stylua, shfmt | `conform.lua` |
| Linters    | oxlint (JS/TS), shellcheck, cspell (spelling, most filetypes) | `lint.lua` |

Formatting runs on save. `:ConformInfo` and `:LintInfo` show what's active in
the current buffer.

## Maintenance

- `:Lazy sync`: update plugins, then commit `lazy-lock.json`
- `:Mason`: see or update installed tools
- `:checkhealth`: when something's off
