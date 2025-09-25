return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	version = "*",
	config = function()
		require("neogen").setup({
			enabled = true,
			input_after_comment = true, -- Enter input mode after generating

			-- Language-specific configurations
			languages = {
				javascript = {
					template = {
						annotation_convention = "jsdoc", -- JSDoc style
					},
				},
				typescript = {
					template = {
						annotation_convention = "jsdoc", -- JSDoc for TypeScript too
					},
				},
				javascriptreact = {
					template = {
						annotation_convention = "jsdoc",
					},
				},
				typescriptreact = {
					template = {
						annotation_convention = "jsdoc",
					},
				},
				cpp = {
					template = {
						annotation_convention = "doxygen", -- Doxygen for C++
					},
				},
				c = {
					template = {
						annotation_convention = "doxygen",
					},
				},
				python = {
					template = {
						annotation_convention = "google_docstrings", -- Google style for Python
					},
				},
				lua = {
					template = {
						annotation_convention = "ldoc", -- LDoc for Lua
					},
				},
				rust = {
					template = {
						annotation_convention = "rustdoc",
					},
				},
				java = {
					template = {
						annotation_convention = "javadoc",
					},
				},
			},

			-- No snippet engine - generate plain text
			-- This avoids dependency issues
			snippet_engine = nil,

			-- Placeholders used in function signature
			placeholders_text = {
				["description"] = "[TODO:description]",
				["tparam"] = "[TODO:parameter]",
				["parameter"] = "[TODO:parameter]",
				["return"] = "[TODO:return]",
				["class"] = "[TODO:class]",
				["throw"] = "[TODO:throw]",
				["varargs"] = "[TODO:varargs]",
				["type"] = "[TODO:type]",
				["attribute"] = "[TODO:attribute]",
				["args"] = "[TODO:args]",
				["kwargs"] = "[TODO:kwargs]",
			},

			-- Use treesitter to locate the current function/class context
			enable_placeholders = false, -- Disable since we're not using snippets
		})

		-- Keymaps for documentation generation
		local keymap = vim.keymap

		-- Main documentation generation
		keymap.set("n", "<leader>cd", function()
			require("neogen").generate()
		end, { desc = "Generate documentation" })

		-- Specific documentation types
		keymap.set("n", "<leader>cdf", function()
			require("neogen").generate({ type = "func" })
		end, { desc = "Generate function documentation" })

		keymap.set("n", "<leader>cdc", function()
			require("neogen").generate({ type = "class" })
		end, { desc = "Generate class documentation" })

		keymap.set("n", "<leader>cdt", function()
			require("neogen").generate({ type = "type" })
		end, { desc = "Generate type documentation" })

		keymap.set("n", "<leader>cdF", function()
			require("neogen").generate({ type = "file" })
		end, { desc = "Generate file documentation" })
	end,
}
