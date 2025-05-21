return {
	"tannerdavison/claude.nvim", -- This name is just for identification, not a real repo
	lazy = false,
	dev = true, -- Mark as development plugin
	dir = vim.fn.stdpath("config") .. "/lua/tannerdavison/core", -- Directory containing the module
	config = function()
		require("tannerdavison.core.claude").setup({
			-- You should specify all required fields to satisfy the type checker
			api_key = nil, -- Will use ANTHROPIC_API_KEY environment variable
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
		})
	end,
}
