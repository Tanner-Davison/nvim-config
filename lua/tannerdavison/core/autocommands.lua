-- Autocommand to fold multiline comments on file open
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = "*",
	callback = function()
		-- Wait for treesitter to be ready
		vim.schedule(function()
			local bufnr = vim.api.nvim_get_current_buf()
			
			-- Check if treesitter is available for this buffer
			local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
			if not has_parser or not parser then
				return
			end

			-- Parse the buffer
			local trees = parser:parse()
			if not trees or #trees == 0 then
				return
			end
			
			local tree = trees[1]
			local lang = parser:lang()

			-- Try different comment node patterns for different languages
			local comment_patterns = {
				"(comment) @comment",
				"(line_comment) @comment", 
				"(block_comment) @comment",
				"(documentation_comment) @comment",
				"(multiline_comment) @comment"
			}

			-- Try each pattern until one works
			local successful_query = nil
			for _, pattern in ipairs(comment_patterns) do
				local ok, query = pcall(vim.treesitter.query.parse, lang, pattern)
				if ok and query then
					-- Test if the query actually finds nodes by checking a small portion
					local has_matches = false
					for _ in query:iter_captures(tree:root(), bufnr, 0, math.min(10, vim.api.nvim_buf_line_count(bufnr))) do
						has_matches = true
						break
					end
					if has_matches then
						successful_query = query
						break
					end
				end
			end

			if not successful_query then
				return -- No suitable comment pattern found for this language
			end

			-- Iterate through all comments and create folds
			for _, node in successful_query:iter_captures(tree:root(), bufnr, 0, -1) do
				local start_row, _, end_row, _ = node:range()
				
				-- If comment spans multiple lines, create a fold
				if end_row > start_row then
					-- Create fold from start to end line (using 1-based line numbers)
					-- Use pcall to avoid errors if folding fails
					pcall(vim.cmd, string.format("%d,%dfold", start_row + 1, end_row + 1))
				end
			end
		end)
	end,
})
