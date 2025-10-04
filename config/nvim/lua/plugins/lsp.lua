local M = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
  },
  opts = {
    servers = {
      astro = {},
      bashls = {},
      jsonls = {},
      ts_ls = {},
      lua_ls = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          workspace = { library = vim.api.nvim_get_runtime_file('', true) },
          telemetry = { enable = false },
          diagnostics = { globals = { 'vim' } },
        },
      },
      cssls = {},
      tailwindcss = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
              { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            },
          },
        },
      },
      prismals = {},
    },
  },
  config = function(_, opts)
    -- shared on_attach
    local on_attach = function(_, buf)
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = buf, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

      nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      nmap('gD', vim.lsp.buf.type_definition, '[G]oto Type [D]efinition')

      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      nmap('<leader>co', function()
        vim.lsp.buf_request_sync(0, 'workspace/executeCommand', {
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(0) },
        }, 1000)
      end, 'Organize Imports')

      -- See `:help K` for why this keymap
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    end

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Setup required for ufo
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    for server_name, settings in pairs(opts.servers) do
      vim.lsp.config(server_name, {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = settings,
      })
    end

    vim.lsp.enable(vim.tbl_keys(opts.servers))
  end,
}

return M
