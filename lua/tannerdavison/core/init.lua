-- Performance optimizations
vim.opt.updatetime = 50 -- Faster response time for plugins
vim.opt.timeoutlen = 200 -- Faster key sequence timeout
vim.opt.lazyredraw = true -- Don't redraw during macro execution
vim.opt.synmaxcol = 200 -- Limit syntax highlighting to 200 columns
vim.opt.redrawtime = 1000 -- Faster redraw timeout
vim.opt.maxmempattern = 1000 -- Reduce memory usage for patterns

-- Neovim 0.12.x ships with a Lua treesitter parser/query ABI mismatch --
-- confirmed upstream bug, reproduces even on `nvim --clean` with zero
-- plugins (github.com/flathub/io.neovim.nvim/issues/125,
-- github.com/NixOS/nixpkgs/issues/545818). Neovim's own bundled
-- ftplugin/lua.lua calls vim.treesitter.start() unconditionally with no
-- pcall guard, so opening/restoring a .lua file crashes session restore.
-- This wraps the API itself so ANY caller -- ours or Neovim's own core
-- ftplugin -- fails quietly instead of throwing. Safe to remove once
-- upstream ships a fix (bundled parser catching up to the bundled query,
-- or vice versa).
do
	local orig_start = vim.treesitter.start
	vim.treesitter.start = function(...)
		local ok, err = pcall(orig_start, ...)
		-- Only surface the specific upstream ABI-mismatch signature (the
		-- "Invalid field name ... operator" query error). Every other
		-- treesitter.start failure -- e.g. no parser for virtual filetypes
		-- like snacks_notif, alpha, snacks_picker_input -- was always silently
		-- swallowed by callers' own pcall(vim.treesitter.start), and should
		-- stay silent; don't turn ordinary "no parser for this filetype"
		-- misses into notification spam.
		if not ok and tostring(err):find("operator", 1, true) then
			vim.schedule(function()
				vim.notify(
					"treesitter.start failed (upstream lua parser/query mismatch) -- highlighting skipped for this buffer",
					vim.log.levels.WARN
				)
			end)
		end
	end
end

-- Additional performance optimizations
vim.opt.hidden = true -- Don't unload buffers when abandoned
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup files on write
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Keep undo files (user uses undo frequently)

require("tannerdavison.core.options")
require("tannerdavison.core.keymaps")
require("tannerdavison.core.title")
require("tannerdavison.core.autocommands")
require("tannerdavison.core.agents")

-- Diagnostics (Neovim 0.12 style: signs are configured here, not via sign_define).
-- Inline text is rendered by tiny-inline-diagnostic.nvim, so built-in virtual_text is off.
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✘",
			[vim.diagnostic.severity.WARN] = "⚠",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "💡",
		},
	},
	virtual_text = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = true },
})

-- Neovim 0.12 experimental ui2: redesigned messages + cmdline (fewer "Press ENTER"
-- prompts, pager is a real buffer). Wrapped in pcall so a future API change can
-- never break startup. Set vim.g.tanner_ui2 = false to turn it off.
if vim.g.tanner_ui2 ~= false then
	local ok, ui2 = pcall(require, "vim._core.ui2")
	if ok and type(ui2.enable) == "function" then
		pcall(ui2.enable, {})
	end
end
