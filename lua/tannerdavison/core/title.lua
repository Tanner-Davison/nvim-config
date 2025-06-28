-- -- Set terminal title to show directory/filename
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile", "BufRead" }, {
	callback = function()
		local filepath = vim.fn.expand("%:p")
		if filepath ~= "" then
			local parent_dir = vim.fn.fnamemodify(filepath, ":h:t")
			local filename = vim.fn.expand("%:t")
			io.write("\027]0;Neovim - " .. parent_dir .. "/" .. filename .. "\007")
			io.flush()
		else
			local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
			io.write("\027]0;Neovim - " .. cwd .. "\007")
			io.flush()
		end
	end,
})
