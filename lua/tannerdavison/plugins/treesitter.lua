return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- nvim-treesitter's `main` branch is a full, incompatible rewrite of the
		-- plugin -- the old `master` branch (which this used to be pinned to) is
		-- now frozen/legacy and increasingly breaks on newer Neovim releases
		-- (that mismatch is exactly what caused the "attempt to call method
		-- 'range' (a nil value)" crash). There's no more central
		-- `nvim-treesitter.configs.setup({...})` call -- parser installation and
		-- feature activation (highlighting/indent) are now separate steps.
		require("nvim-treesitter").setup({})

		-- ensure these language parsers are installed (customized for your usage)
		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"graphql",
			"bash",
			"lua",
			"vim",
			"gitignore",
			"c",
			"cpp",
			"cmake",
		})

		-- Start highlighting + treesitter-based indentation per-buffer. This
		-- replaces the old `highlight.enable`/`indent.enable` config table --
		-- main branch expects you to wire these up yourself via core Neovim's
		-- own vim.treesitter API. pcall guards buffers whose language doesn't
		-- have a parser installed (e.g. something not in the list above).
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- NOTE: `incremental_selection` (the old <C-space> expand-selection
		-- keymaps) has no equivalent in the main-branch rewrite -- it was
		-- dropped, not just renamed. <C-space> is currently unbound; say the
		-- word if you want a replacement plugin/snippet for it.

		-- nvim-ts-autotag now configures itself independently of
		-- nvim-treesitter's (now-removed) unified .configs.setup() table --
		-- its own README says the old integration "has been deprecated".
		require("nvim-ts-autotag").setup()
	end,
}
