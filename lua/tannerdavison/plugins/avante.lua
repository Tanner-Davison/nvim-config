-- Copyright 2023 Tanner Davison
-- DISABLED: Using Neural instead for better Claude compatibility
-- To re-enable, remove the 'enabled = false' line below
return {
	"yetone/avante.nvim",
	enabled = false, -- DISABLED: Using Neural instead
	event = "VeryLazy",
	lazy = false,
	version = false,
	opts = {
		provider = "openai", -- Back to Groq as default (more stable)
		providers = {
			-- Groq provider (fast, current default)
			openai = {
				endpoint = "https://api.groq.com/openai/v1",
				model = "moonshotai/kimi-k2-instruct-0905",
				api_key_name = "GROQ_API_KEY",
				extra_request_body = {
					temperature = 0.5,
					max_tokens = 4096,
					top_p = 1,
					frequency_penalty = 0.5,
					presence_penalty = 0.5,
				},
			},
			-- Claude provider - working configuration
			claude = {
				api_key_name = "ANTHROPIC_API_KEY",
				model = "claude-3-5-sonnet-20241022", -- Correct model name
				extra_request_body = {
					max_tokens = 8192,
					temperature = 0.2,
				},
			},
		},

		-- Much safer behavior settings
		behavior = {
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false, -- Never auto-apply!
			support_paste_from_clipboard = false, -- Can cause issues
			auto_save_on_edit = false, -- Don't auto-save
			auto_suggestions_delay_ms = 500, -- Slower to prevent spam
		},

		-- More stable window configuration
		windows = {
			position = "right",
			wrap = true,
			width = 50, -- Slightly wider for better readability
			height = 0.8, -- Don't take full height
			winbar = true, -- Show window bar
			focus_on_open = false, -- Don't steal focus
		},

		-- Diff and edit settings for better control
		diff = {
			autojump = false, -- Don't auto-jump to changes
			list_opener = "split", -- Open diffs in split
			override = false, -- Don't override existing diffs
		},

		-- Edit mode settings
		edit = {
			confirm_changes = true, -- Always confirm changes!
			show_diff = true, -- Show what will change
			auto_backup = true, -- Create backups
			undo_support = true, -- Support undo
		},

		keymaps = {
			ask = "<leader>aa", -- Ask Avante a question
			edit = "<leader>ae", -- Edit with confirmation
			refresh = "<leader>ar", -- Refresh Avante
			accept = "<leader>ay", -- Accept changes (y for yes)
			reject = "<leader>an", -- Reject changes (n for no)
			show_diff = "<leader>ad", -- Show diff before applying
			toggle = {
				debug = "<leader>aD", -- Debug mode (capital D)
				hint = "<leader>ah", -- Hint mode
				suggestion = "<leader>as", -- Toggle suggestions
			},
			eval = {
				confirm = "<CR>", -- Enter to confirm
				cancel = "<Esc>", -- Escape to cancel
			},
			-- Provider switching keymaps
			provider = {
				switch_groq = "<leader>ag", -- Switch to Groq (fast)
				switch_claude = "<leader>aC", -- Switch to Claude (smart)
			},
		},

		-- Performance and stability settings
		performance = {
			timeout = 30000, -- 30 second timeout
			max_retries = 2, -- Don't spam API
			rate_limit_delay = 1000, -- 1 second between requests
		},

		-- Logging for debugging glitches
		log_level = "info", -- Set to "debug" if you need more info
		log_file = "~/.local/state/nvim/avante.log",
	},
	config = function(_, opts)
		require("avante").setup(opts)
		
		-- Custom provider switching functions
		local function switch_provider(provider_name)
			require("avante.config").override({provider = provider_name})
			vim.notify("Switched to " .. provider_name .. " provider", vim.log.levels.INFO)
		end
		
		-- Add keymaps for provider switching
		vim.keymap.set("n", "<leader>ag", function()
			switch_provider("openai")
		end, { desc = "Switch Avante to Groq (fast)" })
		
		vim.keymap.set("n", "<leader>aC", function()
			switch_provider("claude")
		end, { desc = "Switch Avante to Claude (smart)" })
		
		-- Show current provider
		vim.keymap.set("n", "<leader>ap", function()
			local current = require("avante.config").provider
			local provider_names = {
				openai = "Groq (Fast)",
				claude = "Claude (Smart)"
			}
			vim.notify("Current provider: " .. (provider_names[current] or current), vim.log.levels.INFO)
		end, { desc = "Show current Avante provider" })
	end,
	build = "make",
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
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
		repo_map = {
			ignore_patterns = {
				"%.git",
				"node_modules",
				"%.next",
				"%.nuxt",
				"__pycache__",
				"%.pytest_cache",
				"build",
				"dist",
				"%.DS_Store",
			},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
