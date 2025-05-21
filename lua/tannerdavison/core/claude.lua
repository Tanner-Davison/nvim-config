---@class Claude
---@field config ClaudeConfig
local Claude = {}

---@class ClaudeConfig
---@field api_key string|nil API key for Claude (defaults to ANTHROPIC_API_KEY env variable)
---@field model string The Claude model to use
---@field max_tokens integer Maximum number of tokens in the response
---@field temperature number Temperature setting for response randomness
---@field stream boolean Whether to use streaming API for real-time responses
---@field base_url string The base URL for the Claude API
---@field headers table Additional headers to send with requests
---@field default_title string Default title for response windows
---@field window table Window appearance configuration
---@field highlight boolean Whether to highlight code in responses
---@field shortcuts table Keyboard shortcuts for the plugin
---@field templates table Predefined templates for common prompts

-- Default configuration
local default_config = {
	api_key = nil, -- Will fallback to ANTHROPIC_API_KEY env variable
	model = "claude-3-7-sonnet-20250219",
	max_tokens = 4000,
	temperature = 0.7,
	stream = true,
	base_url = "https://api.anthropic.com/v1",
	headers = {
		["anthropic-version"] = "2023-06-01",
		["content-type"] = "application/json",
	},
	default_title = "Claude Response",
	window = {
		width_ratio = 0.8,
		height_ratio = 0.8,
		border = "rounded",
		title_pos = "center",
		wrap = true,
		cursorline = true,
	},
	highlight = true,
	shortcuts = {
		close = { "q", "<Esc>" },
		copy = "y",
		apply_code = "<CR>",
	},
	templates = {
		explain = "Explain the following code in detail:\n\n```{{filetype}}\n{{selection}}\n```",
		complete = "Complete the following code. Only output the completed code without explanation.\n\n```{{filetype}}\n{{selection}}\n```",
		refactor = "Refactor the following code to improve its clarity, efficiency, and maintainability. Explain your changes.\n\n```{{filetype}}\n{{selection}}\n```",
		document = "Generate comprehensive documentation for the following code:\n\n```{{filetype}}\n{{selection}}\n```",
		fix = "Fix the following code. Explain the issues and your fixes.\n\n```{{filetype}}\n{{selection}}\n```",
		test = "Generate unit tests for the following code:\n\n```{{filetype}}\n{{selection}}\n```",
	},
}

-- Internal state
local state = {
	config = vim.deepcopy(default_config),
	conversations = {}, -- Store conversation history by conversation ID
	buffers = {}, -- Store active buffer IDs
	current_request = nil, -- Track current request for cancellation
}

---@param opts ClaudeConfig|nil
function Claude.setup(opts)
	if opts then
		state.config = vim.tbl_deep_extend("force", state.config, opts)
	end

	-- Create user commands
	vim.api.nvim_create_user_command("Claude", function(args)
		Claude.prompt(args.args)
	end, { nargs = "*", desc = "Ask Claude a question" })

	vim.api.nvim_create_user_command("ClaudeSelection", function(args)
		local selection = Claude.get_visual_selection()
		if selection then
			Claude.query_claude_with_context(selection, args.args)
		end
	end, { nargs = "*", desc = "Ask Claude about selected text" })

	-- Create commands for each template
	for name, _ in pairs(state.config.templates) do
		local command_name = "Claude" .. name:gsub("^%l", string.upper)
		vim.api.nvim_create_user_command(command_name, function()
			local selection = Claude.get_visual_selection()
			if selection then
				Claude.use_template(name, selection)
			end
		end, { desc = "Use Claude " .. name .. " template on selection" })
	end

	-- Add key mappings if user wants them
	if state.config.mappings then
		for mode, mappings in pairs(state.config.mappings) do
			for key, mapping in pairs(mappings) do
				vim.keymap.set(mode, key, mapping.command, {
					desc = mapping.desc,
					noremap = true,
					silent = true,
				})
			end
		end
	end
end

--- Get the visual selection
---@return string|nil selection
function Claude.get_visual_selection()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "" then
		-- If not in visual mode, check if there are marks for previous selection
		local marks = vim.fn.getpos("'<"), vim.fn.getpos("'>")
		if marks[1][2] == 0 then -- No marks
			vim.notify("No selection found", vim.log.levels.ERROR)
			return nil
		end
	end

	local start_line, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
	local end_line, end_col = unpack(vim.fn.getpos("'>"), 2, 3)

	-- Account for multi-byte characters
	start_col = vim.fn.byteidx(vim.fn.getline(start_line), start_col - 1) + 1
	end_col = vim.fn.byteidx(vim.fn.getline(end_line), end_col - 1) + 1

	-- Get the selected lines
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Adjust first and last line to account for partial selection
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return table.concat(lines, "\n")
end

--- Create a buffer for Claude responses
---@param title string|nil The title for the buffer window
---@param conversation_id string|nil The conversation ID
---@return integer, integer The buffer ID and window ID
function Claude.create_claude_buffer(title, conversation_id)
	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Set buffer name
	local buffer_title = title or state.config.default_title
	vim.api.nvim_buf_set_name(buf, buffer_title)

	-- Create a new window
	local width = math.floor(vim.o.columns * state.config.window.width_ratio)
	local height = math.floor(vim.o.lines * state.config.window.height_ratio)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = state.config.window.border,
		title = buffer_title,
		title_pos = state.config.window.title_pos,
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", state.config.window.wrap)
	vim.api.nvim_win_set_option(win, "cursorline", state.config.window.cursorline)

	-- Add keymaps for the window
	for _, key in ipairs(state.config.shortcuts.close) do
		vim.api.nvim_buf_set_keymap(buf, "n", key, ":close<CR>", { noremap = true, silent = true })
	end

	-- Add copy keymap
	vim.api.nvim_buf_set_keymap(buf, "n", state.config.shortcuts.copy, '"+y', { noremap = true, silent = true })

	-- Add apply code keymap
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		state.config.shortcuts.apply_code,
		":lua require('tannerdavison.core.claude').apply_code()<CR>",
		{ noremap = true, silent = true }
	)

	-- Store buffer info
	if conversation_id then
		state.buffers[buf] = {
			conversation_id = conversation_id,
			win = win,
		}
	end

	return buf, win
end

--- Apply code from Claude response to current buffer
function Claude.apply_code()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	-- Find code blocks
	local code_blocks = {}
	local in_code_block = false
	local start_line = nil
	local language = nil

	for i, line in ipairs(lines) do
		if not in_code_block and line:match("^```(.*)$") then
			in_code_block = true
			start_line = i
			language = line:match("^```(.*)$"):gsub("%s+", "")
		elseif in_code_block and line:match("^```$") then
			table.insert(code_blocks, {
				start = start_line,
				finish = i,
				lang = language,
				content = table.concat(vim.list_slice(lines, start_line + 1, i - 1), "\n"),
			})
			in_code_block = false
		end
	end

	if #code_blocks == 0 then
		vim.notify("No code blocks found", vim.log.levels.WARN)
		return
	end

	-- If multiple code blocks, let user select which one
	local selected_block
	if #code_blocks == 1 then
		selected_block = code_blocks[1]
	else
		local options = {}
		for i, block in ipairs(code_blocks) do
			table.insert(options, i .. ": " .. block.lang .. " (" .. (block.finish - block.start - 1) .. " lines)")
		end

		vim.ui.select(options, {
			prompt = "Select code block to apply:",
		}, function(choice, idx)
			if idx then
				selected_block = code_blocks[idx]
			end
		end)
	end

	if not selected_block then
		return
	end

	-- Apply to original buffer
	local original_buf = vim.fn.bufnr("#")
	if original_buf ~= -1 then
		-- First close the Claude buffer
		vim.api.nvim_command("close")

		-- Switch to original buffer
		vim.api.nvim_set_current_buf(original_buf)

		-- Get current visual selection if available
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		-- Fix: Use safer approach to insert text
		if start_pos[2] ~= 0 and end_pos[2] ~= 0 then
			-- Replace selection with code
			local split_content = vim.split(selected_block.content, "\n")

			-- Get the line contents to determine valid column ranges
			local start_line_content = vim.api.nvim_buf_get_lines(original_buf, start_pos[2] - 1, start_pos[2], false)[1]
				or ""
			local end_line_content = vim.api.nvim_buf_get_lines(original_buf, end_pos[2] - 1, end_pos[2], false)[1]
				or ""

			-- Ensure columns are within valid ranges
			local start_col = math.min(start_pos[3] - 1, #start_line_content)
			local end_col = math.min(end_pos[3], #end_line_content)

			-- Apply the text replacement
			vim.api.nvim_buf_set_text(original_buf, start_pos[2] - 1, start_col, end_pos[2] - 1, end_col, split_content)
		else
			-- Just insert at cursor position
			local cursor = vim.api.nvim_win_get_cursor(0)
			local line_content = vim.api.nvim_buf_get_lines(original_buf, cursor[1] - 1, cursor[1], false)[1] or ""
			local col = math.min(cursor[2], #line_content)

			vim.api.nvim_buf_set_text(
				original_buf,
				cursor[1] - 1,
				col,
				cursor[1] - 1,
				col,
				vim.split(selected_block.content, "\n")
			)
		end

		vim.notify("Code applied successfully", vim.log.levels.INFO)
	else
		vim.notify("Original buffer not found", vim.log.levels.ERROR)
	end
end
--- Format prompt with template
---@param template string The template string
---@param vars table Variables to insert into template
---@return string formatted_prompt
function Claude.format_template(template, vars)
	local result = template
	for key, value in pairs(vars) do
		result = result:gsub("{{" .. key .. "}}", value)
	end
	return result
end

--- Use a predefined template
---@param template_name string Name of template to use
---@param selection string The selected text
---@param additional_context string|nil Additional context to add
function Claude.use_template(template_name, selection, additional_context)
	local template = state.config.templates[template_name]
	if not template then
		vim.notify("Template not found: " .. template_name, vim.log.levels.ERROR)
		return
	end

	local filetype = vim.bo.filetype
	local vars = {
		selection = selection,
		filetype = filetype,
	}

	local prompt = Claude.format_template(template, vars)
	if additional_context then
		prompt = prompt .. "\n\n" .. additional_context
	end

	Claude.query_claude(prompt, nil, "Claude: " .. template_name:gsub("^%l", string.upper))
end

--- Generate a unique conversation ID
---@return string conversation_id
function Claude.generate_conversation_id()
	return tostring(os.time()) .. "_" .. tostring(math.random(10000))
end

--- Handle API response streaming
---@param buf integer Buffer ID
---@param response_file string Path to response file
---@param conversation_id string Conversation ID
---@param win integer Window ID
function Claude.handle_streaming_response(buf, response_file, conversation_id, win)
	local content_lines = {}
	local partial_line = ""
	local response_file_handle = io.open(response_file, "r")

	-- Check if file was opened successfully
	if not response_file_handle then
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"Error: Could not open response file stream",
			})
		end)
		return
	end

	-- Set up a timer to periodically check for new content
	local timer = vim.loop.new_timer()
	timer:start(
		100,
		100,
		vim.schedule_wrap(function()
			local new_content = response_file_handle:read("*line")

			if new_content then
				-- Process the stream data
				if new_content:match("^data: ") then
					local data = new_content:sub(7) -- Remove "data: " prefix

					if data == "[DONE]" then
						timer:stop()
						response_file_handle:close()
						os.remove(response_file)
						return
					end

					local success, json_data = pcall(vim.fn.json_decode, data)
					if success and json_data then
						-- Extract text from the response
						if json_data.type == "content_block_delta" and json_data.delta and json_data.delta.text then
							partial_line = partial_line .. json_data.delta.text

							-- Split by newlines to update buffer
							local lines = {}
							for line in (partial_line .. "\n"):gmatch("(.-)\n") do
								table.insert(lines, line)
							end

							-- Last element is the new partial line
							if #lines > 0 then
								partial_line = lines[#lines]
								table.remove(lines, #lines)
							end

							-- Update buffer with complete lines
							if #lines > 0 then
								vim.schedule(function()
									if vim.api.nvim_buf_is_valid(buf) then
										-- Append new lines to content_lines
										for _, line in ipairs(lines) do
											table.insert(content_lines, line)
										end

										-- Update the buffer with all content lines and partial line
										local all_lines = vim.deepcopy(content_lines)
										table.insert(all_lines, partial_line)
										vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)

										-- Process code blocks for syntax highlighting
										if state.config.highlight then
											Claude.highlight_code_blocks(buf)
										end

										-- Scroll to bottom if window is still valid
										if vim.api.nvim_win_is_valid(win) then
											vim.api.nvim_win_set_cursor(win, { #all_lines, 0 })
										else
											-- Window was closed, stop the timer
											timer:stop()
											response_file_handle:close()
											os.remove(response_file)
										end
									else
										-- Buffer was deleted, stop the timer
										timer:stop()
										response_file_handle:close()
										os.remove(response_file)
									end
								end)
							end
						end

						-- If this is a message_stop event, we're done with this response
						if json_data.type == "message_stop" then
							-- Add the last partial line to content_lines if not empty
							if partial_line ~= "" then
								table.insert(content_lines, partial_line)
								partial_line = ""
							end

							-- Update conversation history
							if conversation_id and json_data.message then
								if not state.conversations[conversation_id] then
									state.conversations[conversation_id] = {}
								end

								-- Store assistant's response in conversation history
								table.insert(state.conversations[conversation_id], {
									role = "assistant",
									content = table.concat(content_lines, "\n"),
								})
							end

							-- Final update to the buffer
							vim.schedule(function()
								if vim.api.nvim_buf_is_valid(buf) then
									vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)

									-- Process code blocks for syntax highlighting
									if state.config.highlight then
										Claude.highlight_code_blocks(buf)
									end

									-- Set buffer as not modified
									vim.api.nvim_buf_set_option(buf, "modified", false)
								end
							end)

							timer:stop()
							response_file_handle:close()
							os.remove(response_file)
						end
					end
				end
			end
		end)
	)
end

--- Highlight code blocks in buffer
---@param buf integer Buffer ID
function Claude.highlight_code_blocks(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local in_code_block = false
	local start_line = nil
	local language = nil

	for i, line in ipairs(lines) do
		if not in_code_block and line:match("^```(.*)$") then
			in_code_block = true
			start_line = i - 1
			language = line:match("^```(.*)$"):gsub("%s+", "")

			-- If language is empty, try to infer from filetype
			if language == "" then
				language = vim.bo.filetype
			end
		elseif in_code_block and line:match("^```$") then
			local end_line = i - 1

			-- Create a namespace for this block if it doesn't exist
			local ns_name = "claude_code_block_" .. start_line .. "_" .. end_line
			local ns_id = vim.api.nvim_create_namespace(ns_name)

			-- Apply syntax highlighting to the block
			vim.api.nvim_buf_set_extmark(buf, ns_id, start_line, 0, {
				end_line = end_line,
				hl_group = "Comment",
			})

			-- Set virtual text for the language
			if language and language ~= "" then
				vim.api.nvim_buf_set_extmark(buf, ns_id, start_line, 0, {
					virt_text = { { language, "Special" } },
					virt_text_pos = "right_align",
				})
			end

			in_code_block = false
		end
	end
end

--- Handle non-streaming API response
---@param buf integer Buffer ID
---@param response_file string Path to response file
---@param conversation_id string Conversation ID
function Claude.handle_non_streaming_response(buf, response_file, conversation_id)
	local response_file_handle = io.open(response_file, "r")
	if response_file_handle then
		local content = response_file_handle:read("*all")
		response_file_handle:close()

		-- Parse JSON response
		local success, response = pcall(vim.fn.json_decode, content)

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

		-- Split the text into lines
		local lines = {}
		for line in (text .. "\n"):gmatch("(.-)\n") do
			table.insert(lines, line)
		end

		-- Update conversation history
		if conversation_id then
			if not state.conversations[conversation_id] then
				state.conversations[conversation_id] = {}
			end

			table.insert(state.conversations[conversation_id], {
				role = "assistant",
				content = text,
			})
		end

		-- Update the buffer
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

				-- Process code blocks for syntax highlighting
				if state.config.highlight then
					Claude.highlight_code_blocks(buf)
				end

				-- Set buffer as not modified
				vim.api.nvim_buf_set_option(buf, "modified", false)
			end
		end)
	else
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"Error: Could not read API response file",
			})
		end)
	end
end

--- Call Claude API with prompt
---@param prompt string The prompt to send to Claude
---@param context table|nil Additional context or options
---@param title string|nil Title for the response window
function Claude.query_claude(prompt, context, title)
	-- Create a conversation ID if none exists
	local ctx = context or {}
	local conversation_id = ctx.conversation_id or Claude.generate_conversation_id()

	-- Create initial buffer and window
	local buf, win = Claude.create_claude_buffer(title, conversation_id)

	-- Set initial content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"# Sending request to Claude...",
		"",
		"Please wait...",
	})

	-- Get API key from config or environment
	local api_key = state.config.api_key or os.getenv("ANTHROPIC_API_KEY")
	if not api_key or api_key == "" then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"Error: API key not found",
			"",
			"Please set api_key in config or ANTHROPIC_API_KEY environment variable",
		})
		return
	end

	-- Build message array with conversation history if available
	local messages = {}

	-- Add conversation history if available
	if state.conversations[conversation_id] then
		messages = vim.deepcopy(state.conversations[conversation_id])
	end

	-- Add current user message
	table.insert(messages, {
		role = "user",
		content = prompt,
	})

	-- Store user message in conversation history
	if not state.conversations[conversation_id] then
		state.conversations[conversation_id] = {}
	end
	table.insert(state.conversations[conversation_id], {
		role = "user",
		content = prompt,
	})

	-- Create a temporary file for the request
	local request_file = os.tmpname()
	local file = io.open(request_file, "w")

	-- Set API parameters
	local request_params = {
		model = ctx.model or state.config.model,
		max_tokens = ctx.max_tokens or state.config.max_tokens,
		temperature = ctx.temperature or state.config.temperature,
		messages = messages,
	}

	-- Add stream parameter if using streaming
	if state.config.stream then
		request_params.stream = true
	end

	-- Write request to file
	file:write(vim.fn.json_encode(request_params))
	file:close()

	-- Create a response file
	local response_file = os.tmpname()

	-- Set up headers
	local headers = {}
	for key, value in pairs(state.config.headers) do
		table.insert(headers, '-H "' .. key .. ": " .. value .. '"')
	end
	table.insert(headers, '-H "x-api-key: ' .. api_key .. '"')

	-- Build curl command
	local api_endpoint = state.config.stream and "/messages" or "/messages"
	local curl_cmd = string.format(
		"curl -s %s %s -d @%s > %s",
		state.config.base_url .. api_endpoint,
		table.concat(headers, " "),
		request_file,
		response_file
	)

	-- Display status notification
	vim.notify("Sending request to Claude...", vim.log.levels.INFO)

	-- Make async API call
	state.current_request = vim.fn.jobstart(curl_cmd, {
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

				-- Clean up temp files
				os.remove(request_file)
				os.remove(response_file)
				return
			end

			-- Parse response based on streaming or non-streaming
			if state.config.stream then
				Claude.handle_streaming_response(buf, response_file, conversation_id, win)
			else
				Claude.handle_non_streaming_response(buf, response_file, conversation_id)

				-- Clean up temp files
				os.remove(request_file)
				os.remove(response_file)
			end

			-- Clear current request
			state.current_request = nil
		end,
	})
end

--- Ask a question with selected text as context
---@param text string The selected text to use as context
---@param context string|nil Additional context from arguments
function Claude.query_claude_with_context(text, context)
	-- Get user input about the selected text
	vim.ui.input({ prompt = "Ask about the selected text: " }, function(input)
		if input then
			-- Combine the selected text and the question
			local prompt = "I have the following text:\n\n```\n" .. text .. "\n```\n\n" .. input

			-- Add additional context if provided
			if context and context ~= "" then
				prompt = prompt .. "\n\n" .. context
			end

			-- Send to Claude
			Claude.query_claude(prompt, nil, "Claude: " .. input:sub(1, 30))
		end
	end)
end

--- Interactive prompt for Claude
---@param args string|nil Arguments from command line
function Claude.prompt(args)
	-- If args is provided, use it as the prompt
	if args and args ~= "" then
		Claude.query_claude(args, nil, "Claude: " .. args:sub(1, 30))
		return
	end

	-- Otherwise, get input from user
	vim.ui.input({ prompt = "Ask Claude: " }, function(input)
		if input and input ~= "" then
			Claude.query_claude(input, nil, "Claude: " .. input:sub(1, 30))
		end
	end)
end

--- Ask Claude to explain code
---@param code string The code to explain
function Claude.explain_code(code)
	local filetype = vim.bo.filetype
	Claude.use_template("explain", code)
end

--- Ask Claude to complete code
---@param code string The code to complete
function Claude.complete_code(code)
	Claude.use_template("complete", code)
end

--- Ask Claude to refactor code
---@param code string The code to refactor
function Claude.refactor_code(code)
	Claude.use_template("refactor", code)
end

--- Ask Claude to document code
---@param code string The code to document
function Claude.generate_docs(code)
	Claude.use_template("document", code)
end

--- Ask Claude to fix code
---@param code string The code to fix
function Claude.fix_code(code)
	Claude.use_template("fix", code)
end

--- Ask Claude to generate tests for code
---@param code string The code to test
function Claude.generate_tests(code)
	Claude.use_template("test", code)
end

--- Cancel the current request if in progress
function Claude.cancel_request()
	if state.current_request then
		vim.fn.jobstop(state.current_request)
		state.current_request = nil
		vim.notify("Claude request cancelled", vim.log.levels.INFO)
	else
		vim.notify("No active Claude request to cancel", vim.log.levels.WARN)
	end
end

--- Clear conversation history
---@param conversation_id string|nil The conversation ID to clear (all if nil)
function Claude.clear_conversation(conversation_id)
	if conversation_id then
		state.conversations[conversation_id] = nil
		vim.notify("Cleared conversation " .. conversation_id, vim.log.levels.INFO)
	else
		state.conversations = {}
		vim.notify("Cleared all conversations", vim.log.levels.INFO)
	end
end

--- Get a list of active conversations
---@return table conversation_list
function Claude.list_conversations()
	local conversations = {}
	for id, messages in pairs(state.conversations) do
		local first_msg = messages[1] and messages[1].content or ""
		local preview = first_msg:sub(1, 30) .. (first_msg:len() > 30 and "..." or "")
		table.insert(conversations, {
			id = id,
			messages = #messages,
			preview = preview,
		})
	end
	return conversations
end

--- Open a floating window with conversation list
function Claude.show_conversations()
	local conversations = Claude.list_conversations()
	if #conversations == 0 then
		vim.notify("No active conversations", vim.log.levels.INFO)
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Create lines for the buffer
	local lines = { "# Claude Conversations", "" }
	for _, conv in ipairs(conversations) do
		table.insert(lines, string.format("%s (%d messages) - %s", conv.id, conv.messages, conv.preview))
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Create a window
	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(#lines + 2, vim.o.lines - 4)
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
		title = "Claude Conversations",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- Add keymaps
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		":lua require('tannerdavison.core.claude').open_conversation()<CR>",
		{ noremap = true, silent = true }
	)
end

--- Open a specific conversation from the conversation list
function Claude.open_conversation()
	local line = vim.fn.getline(".")
	local conversation_id = line:match("^([0-9_]+)")

	if conversation_id and state.conversations[conversation_id] then
		-- Create a buffer to show the conversation
		local buf, win = Claude.create_claude_buffer("Claude Conversation: " .. conversation_id, conversation_id)

		-- Format the conversation
		local lines = {}
		for _, message in ipairs(state.conversations[conversation_id]) do
			table.insert(lines, "# " .. (message.role == "user" and "You" or "Claude"))
			table.insert(lines, "")

			-- Split message content into lines
			for content_line in (message.content .. "\n"):gmatch("(.-)\n") do
				table.insert(lines, content_line)
			end

			table.insert(lines, "")
			table.insert(lines, "---")
			table.insert(lines, "")
		end

		-- Display the conversation
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		-- Add a keybinding to continue the conversation
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			"c",
			":lua require('tannerdavison.core.claude').continue_conversation('" .. conversation_id .. "')<CR>",
			{ noremap = true, silent = true, desc = "Continue conversation" }
		)

		-- Highlight code blocks
		if state.config.highlight then
			Claude.highlight_code_blocks(buf)
		end
	else
		vim.notify("Invalid conversation selection", vim.log.levels.ERROR)
	end
end

--- Continue a conversation with Claude
---@param conversation_id string The conversation ID to continue
function Claude.continue_conversation(conversation_id)
	if not state.conversations[conversation_id] then
		vim.notify("Conversation not found: " .. conversation_id, vim.log.levels.ERROR)
		return
	end

	vim.ui.input({ prompt = "Your message: " }, function(input)
		if input and input ~= "" then
			Claude.query_claude(
				input,
				{ conversation_id = conversation_id },
				"Claude Conversation: " .. conversation_id
			)
		end
	end)
end

--- Create a markdown export of a conversation
---@param conversation_id string The conversation ID to export
---@return string markdown The markdown export of the conversation
function Claude.export_conversation(conversation_id)
	if not state.conversations[conversation_id] then
		vim.notify("Conversation not found: " .. conversation_id, vim.log.levels.ERROR)
		return ""
	end

	local markdown = "# Claude Conversation\n\n"

	for _, message in ipairs(state.conversations[conversation_id]) do
		markdown = markdown .. "## " .. (message.role == "user" and "You" or "Claude") .. "\n\n"
		markdown = markdown .. message.content .. "\n\n"
	end

	return markdown
end

--- Save a conversation to a file
---@param conversation_id string The conversation ID to save
function Claude.save_conversation(conversation_id)
	if not state.conversations[conversation_id] then
		vim.notify("Conversation not found: " .. conversation_id, vim.log.levels.ERROR)
		return
	end

	vim.ui.input({ prompt = "Save conversation to file: " }, function(filename)
		if filename and filename ~= "" then
			local markdown = Claude.export_conversation(conversation_id)

			local file = io.open(filename, "w")
			if file then
				file:write(markdown)
				file:close()
				vim.notify("Conversation saved to " .. filename, vim.log.levels.INFO)
			else
				vim.notify("Failed to save conversation to " .. filename, vim.log.levels.ERROR)
			end
		end
	end)
end

-- Return the module
return Claude
