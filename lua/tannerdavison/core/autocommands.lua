-- Autocommand to fold multiline comments on file open
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = "*",
	callback = function()
		-- Wait for treesitter to be ready
		vim.schedule(function()
			local bufnr = vim.api.nvim_get_current_buf()
			
			-- Check if treesitter is available for this buffer
			local has_parser = pcall(vim.treesitter.get_parser, bufnr)
			if not has_parser then
				return
			end

			-- Get treesitter parser
			local parser = vim.treesitter.get_parser(bufnr)
			if not parser then
				return
			end

			-- Parse the buffer
			local tree = parser:parse()[1]
			if not tree then
				return
			end

			-- Query for comments
			local query = vim.treesitter.query.parse(
				parser:lang(),
				[[
					(comment) @comment
				]]
			)

			-- Iterate through all comments
			for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
				local start_row, _, end_row, _ = node:range()
				
				-- If comment spans multiple lines, create a fold
				if end_row > start_row then
					-- Create fold from start to end line (using 1-based line numbers)
					vim.cmd(string.format("%d,%dfold", start_row + 1, end_row + 1))
				end
			end
		end)
	end,
})
