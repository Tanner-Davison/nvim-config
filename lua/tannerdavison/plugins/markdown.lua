return {
	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npm install",
		config = function()
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 0
			vim.g.mkdp_command_for_global = 0
			vim.g.mkdp_open_to_the_world = 0
			vim.g.mkdp_open_ip = ""
			vim.g.mkdp_browser = ""
			vim.g.mkdp_echo_preview_url = 0
			vim.g.mkdp_browserfunc = ""
			vim.g.mkdp_preview_options = {
				mkit = {},
				katex = {},
				uml = {},
				maid = {},
				disable_sync_scroll = 0,
				sync_scroll_type = "middle",
				hide_yaml_meta = 1,
				sequence_diagrams = {},
				flowchart_diagrams = {},
				content_editable = false,
				disable_filename = 0,
				toc = {},
			}
			vim.g.mkdp_markdown_css = ""
			vim.g.mkdp_highlight_css = ""
			vim.g.mkdp_port = ""
			vim.g.mkdp_page_title = "「${name}」"
		end,
	},

	-- Enhanced markdown editing and syntax highlighting
	{
		"preservim/vim-markdown",
		ft = { "markdown" },
		config = function()
			-- Disable default key mappings to avoid conflicts
			vim.g.vim_markdown_no_default_key_mappings = 1
			
			-- Enhanced syntax highlighting
			vim.g.vim_markdown_highlighting = 1
			vim.g.vim_markdown_math = 1
			vim.g.vim_markdown_frontmatter = 1
			vim.g.vim_markdown_toml_frontmatter = 1
			vim.g.vim_markdown_json_frontmatter = 1
			vim.g.vim_markdown_strikethrough = 1
			vim.g.vim_markdown_autowrite = 1
			vim.g.vim_markdown_edit_url_in = "tab"
			vim.g.vim_markdown_follow_anchor = 1
			vim.g.vim_markdown_anchorexpr = "'<<' . v:anchor . '>>'"
			vim.g.vim_markdown_github_triple_backtick_code_blocks = 1
			
			-- Folding settings
			vim.g.vim_markdown_folding_disabled = 1
			vim.g.vim_markdown_conceal = 0
			vim.g.vim_markdown_conceal_code_blocks = 0
			
			-- List settings
			vim.g.vim_markdown_auto_insert_bullets = 0
			vim.g.vim_markdown_new_list_item_indent = 0
		end,
	},

	-- Markdown completion for nvim-cmp
	{
		"hrsh7th/cmp-omni",
		ft = { "markdown" },
		config = function()
			local cmp = require("cmp")
			cmp.setup.filetype("markdown", {
				sources = cmp.config.sources({
					{ name = "omni" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- Markdown preview keymaps
	{
		"nvim-lua/plenary.nvim",
		ft = { "markdown" },
		config = function()
			-- Markdown preview keymaps
			vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", {
				buffer = true,
				desc = "Toggle Markdown Preview",
				silent = true,
			})
		end,
	},
} 