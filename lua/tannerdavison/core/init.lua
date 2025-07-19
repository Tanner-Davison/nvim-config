require("tannerdavison.core.options")
require("tannerdavison.core.keymaps")
require("tannerdavison.core.title")

-- Temporarily suppress deprecation warnings until plugins are updated
-- These warnings are from telescope.nvim, nvim-cmp, and cmp-path using deprecated APIs
local original_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  -- Only suppress specific deprecation warnings from known plugins
  if name == "client.supports_method" or 
     name == "vim.lsp.util.jump_to_location" or 
     name == "vim.str_utfindex" or
     name == "vim.validate" then
    return
  end
  -- Call original for other deprecations
  return original_deprecate(name, alternative, version, plugin, backtrace)
end

--  diagnostic signs using modern API
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
		},
	},
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
