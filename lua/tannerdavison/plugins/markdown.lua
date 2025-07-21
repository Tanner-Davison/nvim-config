return {
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
} 