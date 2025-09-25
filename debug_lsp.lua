-- LSP Debugging Script
-- Run this with :luafile debug_lsp.lua

print("=== LSP Debug Information ===")

-- Check if typescript-language-server is executable
local ts_executable = vim.fn.executable("typescript-language-server")
print("typescript-language-server executable:", ts_executable == 1 and "YES" or "NO")

if ts_executable == 1 then
    local handle = io.popen("which typescript-language-server")
    local path = handle:read("*a"):gsub("\n", "")
    handle:close()
    print("Path:", path)
end

-- Check current configurations
print("\n=== Configured LSP Servers ===")
local configs = vim.lsp.config
for name, config in pairs(configs) do
    print("- " .. name)
end

-- Try to manually start ts_ls with direct vim.lsp.start
print("\n=== Attempting manual vim.lsp.start ===")
local buf_name = vim.api.nvim_buf_get_name(0)
local root_dir = vim.fs.root(buf_name, { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd()

local success, result = pcall(vim.lsp.start, {
    name = "ts_ls_debug",
    cmd = { "typescript-language-server", "--stdio" },
    root_dir = root_dir,
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
})

if success then
    print("Direct vim.lsp.start: SUCCESS")
    print("Client ID:", result and result.id or "unknown")
else
    print("Direct vim.lsp.start: FAILED")
    print("Error:", result)
end

-- Check active clients
print("\n=== Active LSP Clients ===")
local clients = vim.lsp.get_clients()
if #clients == 0 then
    print("No active clients")
else
    for _, client in ipairs(clients) do
        print("- " .. client.name .. " (id: " .. client.id .. ")")
    end
end
