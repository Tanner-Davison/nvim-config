return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local none_ls = require("none-ls")
			none_ls.setup({
				sources = {
					none_ls.builtins.formatting.clang_format.with({
						command = vim.fn.has("win32") == 1 and "C:\\msys64\\mingw64\\bin\\clang-format.exe"
							or "clang-format",
					}),
				},
			})
		end,
	},
}
