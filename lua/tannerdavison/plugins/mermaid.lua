return {
	"kevalin/mermaid.nvim",
	ft = { "markdown", "mermaid" },
	cmd = { "MermaidRender", "MermaidPreview", "MermaidToggle", "MermaidFormat", "MermaidClear" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("mermaid").setup({
			format = {
				shift_width = 4, -- matches your IndentWidth elsewhere
			},
			lint = {
				enabled = true, -- diagnostics via mermaid-cli (mmdc)
				command = "mmdc", -- requires: npm install -g @mermaid-js/mermaid-cli
			},
			preview = {
				renderer = "mermaid.js", -- browser fallback if you ever use :MermaidPreview
				theme = "default",
			},
		})
	end,
}
