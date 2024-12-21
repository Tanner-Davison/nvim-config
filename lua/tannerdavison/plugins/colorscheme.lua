-- colorscheme.lua
return {
	"Mofiqul/vscode.nvim", -- Use the VS Code plugin
	config = function()
		-- Set the color scheme
		vim.cmd("colorscheme vscode")

		-- Optional: Customizations for Neovim behavior
		vim.g.vscode_style = "dark" -- You can change to "light" if you prefer the light theme
	end,
}
