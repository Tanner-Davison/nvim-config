return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"jay-babu/mason-nvim-dap.nvim",
		"williamboman/mason.nvim",
	},
	event = "VeryLazy",
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- ================================================================
		-- MASON-DAP: auto-install codelldb
		-- ================================================================
		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb" },
			automatic_installation = true,
			handlers = {},
		})

		-- ================================================================
		-- DAP-UI SETUP
		-- ================================================================
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			element_mappings = {},
			expand_lines = true,
			force_buffers = true,
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.35 },
						{ id = "breakpoints", size = 0.15 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 50,
					position = "left",
				},
				{
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
					size = 12,
					position = "bottom",
				},
			},
			floating = {
				max_height = 20,
				max_width = 80,
				border = "rounded",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = "",
					play = "",
					step_into = "",
					step_over = "",
					step_out = "",
					step_back = "",
					run_last = "",
					terminate = "",
					disconnect = "",
				},
			},
			render = {
				max_type_length = nil,
				max_value_lines = 100,
				indent = 1,
			},
		})

		-- ================================================================
		-- DAP VIRTUAL TEXT
		-- ================================================================
		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			clear_on_continue = false,
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})

		-- ================================================================
		-- SIGNS: gutter breakpoint indicators
		-- ================================================================
		local function define_signs()
			local sign_column_hl = vim.api.nvim_get_hl(0, { name = "SignColumn" })
			local bg = sign_column_hl.bg and ("#%06x"):format(sign_column_hl.bg) or nil

			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400", bg = bg, bold = true })
			vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f0a30a", bg = bg, bold = true })
			vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef", bg = bg })
			vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = bg, bold = true })
			vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#304a30", bold = true })
			vim.api.nvim_set_hl(0, "DapStoppedNum", { fg = "#98c379", bold = true })
			vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#656565", bg = bg })

			vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#56b6c2" })
			vim.api.nvim_set_hl(0, "DapUIFloatNormal", { bg = "#1a1b26" })

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedNum" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
		end

		define_signs()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = define_signs })

		-- Widen sign column during debug sessions so both breakpoint + stopped arrow are visible
		local saved_signcolumn = nil
		dap.listeners.before.launch.signcolumn = function()
			saved_signcolumn = vim.wo.signcolumn
			vim.wo.signcolumn = "yes:2"
		end
		dap.listeners.before.attach.signcolumn = function()
			saved_signcolumn = vim.wo.signcolumn
			vim.wo.signcolumn = "yes:2"
		end
		dap.listeners.after.event_terminated.signcolumn = function()
			if saved_signcolumn then
				vim.wo.signcolumn = saved_signcolumn
				saved_signcolumn = nil
			end
		end
		dap.listeners.after.event_exited.signcolumn = function()
			if saved_signcolumn then
				vim.wo.signcolumn = saved_signcolumn
				saved_signcolumn = nil
			end
		end

		-- ================================================================
		-- CODELLDB ADAPTER CONFIG (v1.11.0+ uses stdio)
		-- ================================================================
		local codelldb_cmd = vim.fn.exepath("codelldb")
		if codelldb_cmd == "" then
			local mason_bin = vim.fn.expand("$MASON/bin/codelldb")
			if vim.fn.executable(mason_bin) == 1 then
				codelldb_cmd = mason_bin
			end
		end

		if codelldb_cmd ~= "" then
			dap.adapters.codelldb = {
				type = "executable",
				command = codelldb_cmd,
			}
		end

		-- Fallback: plain lldb-dap adapter
		if vim.fn.executable("lldb-dap") == 1 then
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap",
				name = "lldb",
			}
		elseif vim.fn.executable("lldb-vscode") == 1 then
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-vscode",
				name = "lldb",
			}
		end

		-- ================================================================
		-- C/C++ LAUNCH CONFIGURATIONS
		-- ================================================================
		local function get_cpp_configs()
			local adapter = dap.adapters.codelldb and "codelldb" or "lldb"
			return {
				{
					name = "Launch file",
					type = adapter,
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local input = vim.fn.input("Program arguments: ")
						if input == "" then
							return {}
						end
						return vim.split(input, " ")
					end,
				},
				{
					name = "Launch current file (compile & run)",
					type = adapter,
					request = "launch",
					program = function()
						local file = vim.fn.expand("%:p")
						local out = vim.fn.expand("%:p:r")
						vim.fn.system("g++ -g -O0 -std=c++23 -Wall -Wextra " .. file .. " -o " .. out)
						if vim.v.shell_error ~= 0 then
							vim.notify("Compilation failed! Check terminal for errors.", vim.log.levels.ERROR)
							return nil
						end
						vim.notify("Compiled: " .. out, vim.log.levels.INFO)
						return out
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
				{
					name = "Launch CMake build (Debug)",
					type = adapter,
					request = "launch",
					program = function()
						local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						local exe = vim.fn.getcwd() .. "/build/" .. project_name
						if vim.fn.filereadable(exe) == 1 then
							return exe
						end
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local input = vim.fn.input("Program arguments: ")
						if input == "" then
							return {}
						end
						return vim.split(input, " ")
					end,
				},
				{
					name = "Launch CMake build (break at main)",
					type = adapter,
					request = "launch",
					program = function()
						local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						local exe = vim.fn.getcwd() .. "/build/" .. project_name
						if vim.fn.filereadable(exe) == 1 then
							return exe
						end
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					preRunCommands = { "breakpoint set --name main" },
					args = {},
				},
				{
					name = "Attach to process",
					type = adapter,
					request = "attach",
					pid = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}
		end

		dap.configurations.cpp = get_cpp_configs()
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.objc = dap.configurations.cpp
		dap.configurations.objcpp = dap.configurations.cpp

		-- ================================================================
		-- AUTO OPEN/CLOSE DAP-UI
		-- ================================================================
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- ================================================================
		-- KEYMAPS: <leader>b prefix + function keys
		-- ================================================================
		local keymap = vim.keymap

		-- Function keys (classic debugger feel)
		keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue / Start" })
		keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
		keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
		keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
		keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step out" })

		-- <leader>b prefix (full debug control)
		keymap.set("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
		keymap.set("n", "<leader>bB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Set conditional breakpoint" })
		keymap.set("n", "<leader>bl", function()
			dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end, { desc = "Set log point" })
		keymap.set("n", "<leader>bc", dap.continue, { desc = "Continue" })
		keymap.set("n", "<leader>bi", dap.step_into, { desc = "Step into" })
		keymap.set("n", "<leader>bo", dap.step_over, { desc = "Step over" })
		keymap.set("n", "<leader>bO", dap.step_out, { desc = "Step out" })
		keymap.set("n", "<leader>br", dap.repl.toggle, { desc = "Toggle REPL" })
		keymap.set("n", "<leader>bL", dap.run_last, { desc = "Run last config" })
		keymap.set("n", "<leader>bt", dap.terminate, { desc = "Terminate session" })
		keymap.set("n", "<leader>bd", dap.disconnect, { desc = "Disconnect" })
		keymap.set("n", "<leader>bu", dapui.toggle, { desc = "Toggle DAP UI" })
		local hover_border = {
			{ "╭", "DapUIFloatBorder" },
			{ "─", "DapUIFloatBorder" },
			{ "╮", "DapUIFloatBorder" },
			{ "│", "DapUIFloatBorder" },
			{ "╯", "DapUIFloatBorder" },
			{ "─", "DapUIFloatBorder" },
			{ "╰", "DapUIFloatBorder" },
			{ "│", "DapUIFloatBorder" },
		}
		keymap.set("n", "<leader>be", function()
			dapui.eval(nil, { enter = true })
		end, { desc = "Evaluate expression" })
		keymap.set("v", "<leader>be", function()
			dapui.eval(nil, { enter = true })
		end, { desc = "Evaluate selection" })
		keymap.set("n", "<leader>bh", function()
			local widgets = require("dap.ui.widgets")
			local w = widgets.hover()
			if w then
				vim.api.nvim_win_set_config(w.win, { border = hover_border })
			end
		end, { desc = "Hover value" })
		keymap.set("n", "<leader>bs", function()
			local widgets = require("dap.ui.widgets")
			local w = widgets.centered_float(widgets.scopes)
			if w then
				vim.api.nvim_win_set_config(w.win, { border = hover_border })
			end
		end, { desc = "Scopes (floating)" })
		keymap.set("n", "<leader>bf", function()
			local widgets = require("dap.ui.widgets")
			local w = widgets.centered_float(widgets.frames)
			if w then
				vim.api.nvim_win_set_config(w.win, { border = hover_border })
			end
		end, { desc = "Frames / Stack trace" })
		keymap.set("n", "<leader>bp", dap.pause, { desc = "Pause" })
		keymap.set("n", "<leader>bk", dap.up, { desc = "Go up in stack" })
		keymap.set("n", "<leader>bj", dap.down, { desc = "Go down in stack" })
		keymap.set("n", "<leader>bx", function()
			dap.clear_breakpoints()
			vim.notify("All breakpoints cleared", vim.log.levels.INFO)
		end, { desc = "Clear all breakpoints" })
		keymap.set("n", "<leader>b?", function()
			local breakpoints = require("dap.breakpoints").get()
			local count = 0
			for _, bufs in pairs(breakpoints) do
				count = count + #bufs
			end
			vim.notify("Active breakpoints: " .. count, vim.log.levels.INFO)
		end, { desc = "Count breakpoints" })
	end,
}
