return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local wk = require("which-key")
		
		wk.setup({
			presets = {
				operators = true,
				motions = true,
				text_objects = true,
				windows = true,
				nav = true,
				z = true,
				g = true,
			},
		})
		
		-- Register group labels
		wk.add({
			-- Main leader groups
			{ "<leader>c", group = "C++/Code" },
			{ "<leader>d", group = "Doxygen/Desktop" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>f", group = "Find/Files" },
			{ "<leader>g", group = "Git" },
			{ "<leader>h", group = "Harpoon" },
			{ "<leader>j", group = "Jump" },
			{ "<leader>k", group = "AI Chat" },
			{ "<leader>l", group = "LSP/LazyGit" },
			{ "<leader>m", group = "CMake/Media/Marks" },
			{ "<leader>n", group = "Neovim" },
			{ "<leader>o", group = "Open" },
			{ "<leader>r", group = "React/Replace" },
			{ "<leader>s", group = "Split/Session/Snacks" },
			{ "<leader>t", group = "Tab/TODO/Toggle/Tablet" },
			{ "<leader>w", group = "Window" },
			{ "<leader>x", group = "Trouble/Diagnostics" },
			
			-- Subgroups
			{ "<leader>lw", group = "LSP Workspace" },
			{ "<leader>ld", group = "LSP Document" },
			
			-- Space (non-leader) groups
			{ "<Space>c", group = "C++ Compile" },
		})
	end,
}
