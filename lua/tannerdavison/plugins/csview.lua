return {
	"hat0uma/csvview.nvim",
	ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
	config = function()
		require("csvview").setup({
			-- Optional configuration
			view = {
				--- minimum column width, Defaults to 5
				min_column_width = 5,
				--- spacing between columns, Defaults to 2
				spacing = 2,
				--- The delimiter to use for splitting rows, defaults to "auto"
				--- When delimiter = "auto", the plugin attempts to detect common delimiters automatically
				delimiter = "auto",
			},

			-- Optional: Add comments highlighting
			comments = {
				--- The character(s) that start a comment line
				--- Set to false to disable comment detection
				--- Defaults to "#"
				start = "#",
			},

			-- Optional: Configure cursor behavior
			cursor = {
				--- If true, hides the cursor line in the CSV buffer
				--- Defaults to false
				hide_cursor = false,
			},
		})
	end,
	cmd = {
		"CsvViewEnable",
		"CsvViewDisable",
		"CsvViewToggle",
	},
}
