-- Performance optimizations
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.lazyredraw = false
vim.opt.synmaxcol = 240
vim.opt.redrawtime = 1500
vim.opt.maxmempattern = 2000

require("tannerdavison.core.options")
require("tannerdavison.core.keymaps")
require("tannerdavison.core.title")

-- Temporarily suppress deprecation warnings until plugins are updated
-- These warnings are from telescope.nvim, nvim-cmp, and cmp-path using deprecated APIs
local original_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
	-- Only suppress specific deprecation warnings from known plugins
	if
		name == "client.supports_method"
		or name == "vim.lsp.util.jump_to_location"
		or name == "vim.str_utfindex"
		or name == "vim.validate"
	then
		return
	end
	-- Call original for other deprecations
	return original_deprecate(name, alternative, version, plugin, backtrace)
end

--  diagnostic signs using modern API
vim.diagnostic.config({
	signs = {

		text = {
			[vim.diagnostic.severity.ERROR] = "✘", -- X mark
			[vim.diagnostic.severity.WARN] = "⚠", -- Triangle
			[vim.diagnostic.severity.INFO] = "󰋽", -- Info curse
			[vim.diagnostic.severity.HINT] = "💡", -- Light bulb emoji
		},
	},
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
