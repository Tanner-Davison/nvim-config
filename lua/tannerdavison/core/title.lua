-- -- Set terminal title to show directory/filename
--
-- io.write can fail with "standard file is closed" if this fires very early
-- during startup (e.g. auto-session's conditional_buffer_wipeout closing a
-- placeholder buffer during VimEnter, before stdout is fully attached).
-- Wrapped in pcall since a cosmetic terminal-title failure should never
-- block session restore or throw a hard error.
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile", "BufRead" }, {
	callback = function()
		local filepath = vim.fn.expand("%:p")
		local title

		if filepath ~= "" then
			local parent_dir = vim.fn.fnamemodify(filepath, ":h:t")
			local filename = vim.fn.expand("%:t")
			title = "\027]0;Neovim - " .. parent_dir .. "/" .. filename .. "\007"
		else
			local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
			title = "\027]0;Neovim - " .. cwd .. "\007"
		end

		pcall(function()
			io.write(title)
			io.flush()
		end)
	end,
})
