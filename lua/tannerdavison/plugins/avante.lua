-- 2025-09-23

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
				model = "openai/gpt-oss-120b",
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

		-- Safe behavior settings
		behavior = {
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = true,
		},

		-- Basic window configuration
		windows = {
			position = "right",
			wrap = true,
			width = 40,
		},

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
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
