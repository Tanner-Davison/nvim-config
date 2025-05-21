local M = {}

-- Create a buffer for Claude responses
local function create_claude_buffer(title)
	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Set buffer name
	vim.api.nvim_buf_set_name(buf, title or "Claude Response")

	-- Create a new window
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = title or "Claude Response",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Set some window options
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- Add keymaps for the window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })

	return buf, win
end

-- Call Claude API and display response
function M.query_claude(prompt, template, title)
	-- Create initial buffer and window
	local buf, win = create_claude_buffer(title or "Claude Response")

	-- Set initial content with header
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"# Sending request to Claude...",
		"",
		"Prompt:",
	})

	-- Handle newlines in prompt by splitting into lines
	local prompt_lines = {}
	for line in (prompt .. "\n"):gmatch("(.-)\n") do
		table.insert(prompt_lines, line)
	end

	-- Add prompt lines
	vim.api.nvim_buf_set_lines(buf, 3, 3, false, prompt_lines)

	-- Add footer
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
		"",
		"Please wait...",
	})

	-- Get API key
	local api_key = os.getenv("ANTHROPIC_API_KEY")
	if not api_key or api_key == "" then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"Error: ANTHROPIC_API_KEY environment variable not set",
			"Please set it in your shell with:",
			"",
			"export ANTHROPIC_API_KEY=your-api-key-here",
		})
		return
	end

	-- Format the prompt with template if provided
	if template then
		prompt = template:gsub("{{selection}}", prompt)
	end

	-- Create a temporary file for the request
	local request_file = os.tmpname()
	local file = io.open(request_file, "w")
	-- Escape special characters in prompt
	local escaped_prompt = prompt:gsub('"', '\\"'):gsub("\n", "\\n")
	file:write(
		'{"model":"claude-3-7-sonnet-20250219","max_tokens":4000,"messages":[{"role":"user","content":"'
			.. escaped_prompt
			.. '"}]}'
	)
	file:close()

	-- Create a response file
	local response_file = os.tmpname()

	-- Make async API call
	vim.fn.jobstart(
		'curl -s https://api.anthropic.com/v1/messages -H "x-api-key: '
			.. api_key
			.. '" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" -d @'
			.. request_file
			.. " > "
			.. response_file,
		{
			on_exit = function(_, exit_code)
				-- Handle response
				if exit_code ~= 0 then
					vim.schedule(function()
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
							"Error: API request failed with exit code " .. exit_code,
							"",
							"Please check your API key and internet connection.",
						})
					end)
					return
				end

				-- Read response file
				local response_data = {}
				local response_file_handle = io.open(response_file, "r")
				if response_file_handle then
					local content = response_file_handle:read("*all")
					response_file_handle:close()

					-- Parse JSON response
					local success, response
					success, response = pcall(vim.fn.json_decode, content)

					if not success or not response then
						vim.schedule(function()
							vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
								"Error parsing API response:",
								content,
							})
						end)
						return
					end

					-- Extract the text content
					local text = ""
					if response.content and response.content[1] and response.content[1].text then
						text = response.content[1].text
					end

					-- Format the response
					local lines = { "# Claude Response", "" }

					-- Split the text into lines
					for line in (text .. "\n"):gmatch("(.-)\n") do
						table.insert(lines, line)
					end

					-- Update the buffer
					vim.schedule(function()
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
						vim.api.nvim_buf_set_option(buf, "modified", false)
						vim.api.nvim_buf_set_option(buf, "modifiable", true)
					end)
				else
					vim.schedule(function()
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
							"Error: Could not read API response file",
						})
					end)
				end

				-- Clean up temp files
				os.remove(request_file)
				os.remove(response_file)
			end,
		}
	)
end

-- Ask about selected text
function M.query_claude_with_context(text, title)
	-- Get user input about the selected text
	vim.ui.input({ prompt = "Ask about the selected text: " }, function(input)
		if input then
			-- Combine the selected text and the question
			local prompt = "I have the following text:\n\n```\n" .. text .. "\n```\n\n" .. input

			-- Send to Claude
			M.query_claude(prompt, nil, title or "Claude Response")
		end
	end)
end

-- Call Claude with templates
function M.explain_code(code)
	local filetype = vim.bo.filetype
	local template = "Explain the following code in detail:\n\n```{{filetype}}\n{{selection}}\n```"
	template = template:gsub("{{filetype}}", filetype)
	M.query_claude(code, template, "Claude: Code Explanation")
end

function M.complete_code(code)
	local template = "Complete the following code. Only output the completed code without explanation.\n\n{{selection}}"
	M.query_claude(code, template, "Claude: Code Completion")
end

function M.refactor_code(code)
	local filetype = vim.bo.filetype
	local template =
		"Refactor the following code to improve its clarity, efficiency, and maintainability. Explain your changes.\n\n```{{filetype}}\n{{selection}}\n```"
	template = template:gsub("{{filetype}}", filetype)
	M.query_claude(code, template, "Claude: Code Refactoring")
end

function M.generate_docs(code)
	local filetype = vim.bo.filetype
	local template =
		"Generate comprehensive documentation for the following code:\n\n```{{filetype}}\n{{selection}}\n```"
	template = template:gsub("{{filetype}}", filetype)
	M.query_claude(code, template, "Claude: Documentation Generation")
end

return M
