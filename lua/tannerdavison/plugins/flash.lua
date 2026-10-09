-- Copyright 2026 Tanner Davison
-- flash.nvim: jump to any visible location in a couple of keystrokes.
--
-- IMPORTANT — key choice: flash's *default* keymaps are "s" (jump), "S"
-- (treesitter jump), and "r"/"R" in operator-pending mode. All of those
-- were deliberately NOT used here:
--   - "s" (normal + visual), "S" (normal), "ss" (normal) are already bound
--     by substitute.nvim (operator/line/eol substitute) in
--     plugins/substitute.lua.
--   - "S" (visual) is also bound by nvim-surround's default config in
--     plugins/surround.lua.
-- Everything below lives under the <leader>v prefix, which was completely
-- unused anywhere else in this config (checked every file under plugins/
-- and core/keymaps.lua), so none of it can collide with an existing
-- mapping. char-mode (f/F/t/T) and search-mode ("/", "?") integrations are
-- also explicitly disabled below, so no existing motion or search behavior
-- changes either — only the four <leader>v* keys below do anything new.
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			-- Leave native f/F/t/T character motions completely untouched.
			char = { enabled = false },
			-- Leave native "/" and "?" search completely untouched.
			search = { enabled = false },
		},
	},
	keys = {
		{
			"<leader>vv",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"<leader>vt",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter Jump",
		},
		{
			"<leader>vr",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Flash Remote (operator target, e.g. d<leader>vr)",
		},
		{
			"<leader>vs",
			mode = "o",
			function()
				require("flash").treesitter_search()
			end,
			desc = "Flash Treesitter Search (operator)",
		},
	},
}
