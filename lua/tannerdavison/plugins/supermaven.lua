return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			-- Enable inline completion for ghost text predictions (including multi-line)
			disable_inline_completion = false,
			disable_keymaps = true, -- We'll handle keymaps manually below
			color = {
				suggestion_color = "#808080",
				cterm = 244,
			},
			log_level = "info",
			ignore_filetypes = {
				"bigfile",
				"snacks_input",
				"snacks_notif",
			},
			condition = function()
				return false
			end,
		})

		local suggestion = require("supermaven-nvim.completion_preview")

		-- Smart Tab: accept full multi-line suggestion if present, else fall through
		vim.keymap.set("i", "<Tab>", function()
			if suggestion.has_suggestion() then
				suggestion.on_accept_suggestion()
				return ""
			end
			-- Fall through to default tab behavior (tabout, indent, etc.)
			return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
		end, { expr = true, silent = true, desc = "Accept full AI suggestion or tab" })

		-- Accept just the next word of the suggestion
		vim.keymap.set("i", "<C-j>", function()
			if suggestion.has_suggestion() then
				suggestion.on_accept_suggestion_word()
			end
		end, { silent = true, desc = "Accept one word of AI suggestion" })

		-- Dismiss suggestion
		vim.keymap.set("i", "<C-]>", function()
			suggestion.on_dispose_inlay()
		end, { silent = true, desc = "Clear AI suggestion" })
	end,
}
