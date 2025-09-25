-- Simplified TypeScript LSP setup - replace the ts_ls section in your lspconfig.lua

-- Remove the vim.lsp.config("ts_ls", {...}) block and the autocmd FileType block
-- Replace with this simpler configuration:

local lspconfig = require("lspconfig")

lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Disable formatting in favor of prettier/conform
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
  root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git"),
  settings = {
    typescript = {
      suggest = { autoImports = true },
      preferences = {
        importModuleSpecifier = "non-relative",
        quoteStyle = "single",
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})
