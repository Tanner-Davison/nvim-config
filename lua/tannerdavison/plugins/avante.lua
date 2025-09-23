return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false,
	opts = {
		provider = "openai",
		providers = {
			openai = {
				endpoint = "https://api.groq.com/openai/v1",
				model = "llama-3.3-70b-versatile",
				api_key_name = "GROQ_API_KEY",
				extra_request_body = {
					temperature = 0.5,
					max_tokens = 4096,
					top_p = 1,
					frequency_penalty = 0.5,
					presence_penalty = 0.5,
				},
			},
		},
		-- Enhanced custom tools
		custom_tools = function()
			local tools = {
				-- MCP integration
				require("mcphub.extensions.avante").mcp_tool(),
			}

			-- Add Git integration if available
			if pcall(require, "gitsigns") then
				table.insert(tools, {
					name = "git_status",
					description = "Get current git status and staged changes",
					func = function()
						local result = vim.fn.system("git status --porcelain")
						if vim.v.shell_error == 0 then
							return "Git status:\n" .. result
						else
							return "Not a git repository or git not available"
						end
					end,
				})
			end

			-- Add LSP integration
			table.insert(tools, {
				name = "get_diagnostics",
				description = "Get current buffer LSP diagnostics",
				func = function()
					local bufnr = vim.api.nvim_get_current_buf()
					local diagnostics = vim.diagnostic.get(bufnr)
					if #diagnostics == 0 then
						return "No diagnostics found in current buffer"
					end

					local result = "LSP Diagnostics:\n"
					for _, diag in ipairs(diagnostics) do
						local severity = vim.diagnostic.severity[diag.severity]
						result = result .. string.format("Line %d [%s]: %s\n", diag.lnum + 1, severity, diag.message)
					end
					return result
				end,
			})

			-- Add project context tool
			table.insert(tools, {
				name = "project_context",
				description = "Get current project context and structure",
				func = function()
					local cwd = vim.fn.getcwd()
					local result = "Project: " .. vim.fn.fnamemodify(cwd, ":t") .. "\n"
					result = result .. "Path: " .. cwd .. "\n"

					-- Check for common project files
					local project_files = {
						"package.json",
						"tsconfig.json",
						"next.config.js",
						"Cargo.toml",
						"go.mod",
						"requirements.txt",
						"composer.json",
						"pom.xml",
						"build.gradle",
					}

					result = result .. "\nProject files found:\n"
					for _, file in ipairs(project_files) do
						if vim.fn.filereadable(file) == 1 then
							result = result .. "- " .. file .. "\n"
						end
					end

					return result
				end,
			})

			-- Add buffer context tool
			table.insert(tools, {
				name = "buffer_context",
				description = "Get current buffer information and context",
				func = function()
					local bufnr = vim.api.nvim_get_current_buf()
					local filename = vim.api.nvim_buf_get_name(bufnr)
					local filetype = vim.bo[bufnr].filetype
					local line_count = vim.api.nvim_buf_line_count(bufnr)
					local cursor_pos = vim.api.nvim_win_get_cursor(0)

					local result = string.format(
						"Buffer Info:\n- File: %s\n- Type: %s\n- Lines: %d\n- Cursor: Line %d, Col %d\n",
						filename ~= "" and vim.fn.fnamemodify(filename, ":t") or "[No Name]",
						filetype,
						line_count,
						cursor_pos[1],
						cursor_pos[2] + 1
					)

					-- Add modified status
					if vim.bo[bufnr].modified then
						result = result .. "- Status: Modified\n"
					end

					return result
				end,
			})

			return tools
		end,

		-- Enhanced behavior settings
		behavior = {
			auto_suggestions = false, -- Disable auto suggestions for better control
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = true,
		},

		-- Window configuration
		windows = {
			position = "right", -- or "left", "top", "bottom"
			wrap = true,
			width = 30, -- percentage of screen
			sidebar_header = {
				align = "center", -- left, center, right
				rounded = true,
			},
		},

		disabled_tools = {
			"list_files",
			"search_files",
			"read_file",
			"create_file",
			"rename_file",
			"delete_file",
			"create_dir",
			"rename_dir",
			"delete_dir",
			"bash",
		},

		prompt = {
			loading = "🤖 Asking...",
			result = "✨ Result: ",
			error = "❌ Error: ",
		},

		highlight = {
			prompt = "AvantePrompt",
			result = "AvanteResult",
			error = "AvanteError",
		},

		-- Enhanced keymaps
		keymaps = {
			ask = "<leader>aa",
			edit = "<leader>ae",
			refresh = "<leader>ar",
			toggle = {
				debug = "<leader>ad",
				hint = "<leader>ah",
			},
		},
	},
	build = "make",
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons", -- for icons
		{
			-- Enhanced image support
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					use_absolute_path = true,
				},
			},
		},
		{
			-- Better markdown rendering
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
