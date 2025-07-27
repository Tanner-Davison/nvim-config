-- Performance optimizations
vim.opt.updatetime = 50 -- Faster response time for plugins
vim.opt.timeoutlen = 200 -- Faster key sequence timeout
vim.opt.lazyredraw = true -- Don't redraw during macro execution
vim.opt.synmaxcol = 200 -- Limit syntax highlighting to 200 columns
vim.opt.redrawtime = 1000 -- Faster redraw timeout
vim.opt.maxmempattern = 1000 -- Reduce memory usage for patterns

-- Additional performance optimizations
vim.opt.hidden = true -- Don't unload buffers when abandoned
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup files on write
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Keep undo files (user uses undo frequently)

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
