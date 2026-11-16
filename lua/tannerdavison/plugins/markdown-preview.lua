-- markdown-preview.nvim: real rendered markdown in your browser (live-updates as you type,
-- scroll-synced, with Mermaid diagrams, KaTeX math, real tables and syntax-highlighted code).
-- render-markdown.nvim (markdown-render.lua) still prettifies the buffer itself; this is the
-- "show me the finished document" view. Needs node on PATH.
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		require("lazy").load({ plugins = { "markdown-preview.nvim" } })
		vim.fn["mkdp#util#install"]()
	end,
	init = function()
		vim.g.mkdp_auto_close = 0 -- keep the browser tab open when you switch buffers
		vim.g.mkdp_theme = "dark"
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_echo_preview_url = 1 -- print the URL so you can open it manually if needed
	end,
	keys = {
		{ "<leader>pp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview in browser" },
	},
}
