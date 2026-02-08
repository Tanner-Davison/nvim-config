return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				-- Don't set Tab here - we'll handle it smartly below
				accept_suggestion = nil,
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>", -- Accept just one word at a time
			},
			-- Enable inline completion for ghost text predictions
			disable_inline_completion = false,
			disable_keymaps = false,
			color = {
				suggestion_color = "#808080",
				cterm = 244,
			},
			log_level = "info", -- Set to "off" to disable logging
			ignore_filetypes = {
				"bigfile",
				"snacks_input",
				"snacks_notif",
			},
			condition = function()
				-- Enable Supermaven by default
				return false
			end,
		})

		-- Smart Tab mapping: Supermaven > tabout.nvim
		vim.keymap.set("i", "<Tab>", function()
			local suggestion = require("supermaven-nvim.completion_preview")
			
			-- If Supermaven has a suggestion, accept it
			if suggestion.has_suggestion() then
				suggestion.on_accept_suggestion()
				return
			end
			
			-- Otherwise, fall through to tabout.nvim (default Tab behavior)
			return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
		 end, { expr = true, silent = true, desc = "Accept AI suggestion or tab out" })
	end,
}
