-- Arduino sketches: compile and upload via arduino-cli
-- Requires: arduino-cli installed in WSL (https://arduino.github.io/arduino-cli)
-- Install: curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
-- Then: arduino-cli core install arduino:mbed_giga

return {
	"nvim-lua/plenary.nvim",
	lazy = true,
	ft = { "cpp" },
	config = function()
		local function is_arduino_file()
			return vim.api.nvim_buf_get_name(0):match("%.ino$") ~= nil
		end

		local function get_sketch_dir()
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
		end

		-- Auto-detect the Arduino port (ttyACM0, ttyUSB0, etc.)
		local function detect_port()
			local handle = io.popen("arduino-cli board list 2>/dev/null | grep -v 'No boards' | awk 'NR>1 {print $1}' | head -1")
			if handle then
				local port = handle:read("*l")
				handle:close()
				if port and port ~= "" then return port end
			end
			-- Fallback: check common ports directly
			for _, p in ipairs({ "/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1" }) do
				if vim.fn.filereadable(p) == 1 then return p end
			end
			return nil
		end

		local function run_arduino(action)
			if not is_arduino_file() then
				vim.notify("Not an Arduino sketch (.ino)", vim.log.levels.WARN)
				return
			end

			local sketch = get_sketch_dir()
			local fqbn = "arduino:mbed_giga:giga"  -- Arduino Giga R1

			local cmd
			if action == "compile" then
				cmd = string.format("arduino-cli compile --fqbn %s %s", fqbn, sketch)
			else
				local port = detect_port()
				if not port then
					vim.notify(
						"No Arduino found. Plug it in and run: usbipd attach --wsl --busid <id>",
						vim.log.levels.ERROR,
						{ title = "Arduino" }
					)
					return
				end
				vim.notify("Uploading to " .. port, vim.log.levels.INFO, { title = "Arduino" })
				if action == "upload" then
					cmd = string.format("arduino-cli upload --fqbn %s --port %s %s", fqbn, port, sketch)
				elseif action == "both" then
					cmd = string.format(
						"arduino-cli compile --fqbn %s %s && arduino-cli upload --fqbn %s --port %s %s",
						fqbn, sketch, fqbn, port, sketch
					)
				end
			end

			vim.cmd("botright 12split")
			vim.cmd("terminal " .. cmd)
			vim.cmd("startinsert")
		end

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.ino",
			callback = function()
				local opts = { buffer = true, silent = true }
				vim.keymap.set("n", "<leader>ac", function() run_arduino("compile") end,
					vim.tbl_extend("force", opts, { desc = "Arduino: compile sketch" }))
				vim.keymap.set("n", "<leader>au", function() run_arduino("upload") end,
					vim.tbl_extend("force", opts, { desc = "Arduino: upload sketch" }))
				vim.keymap.set("n", "<leader>ab", function() run_arduino("both") end,
					vim.tbl_extend("force", opts, { desc = "Arduino: compile + upload" }))
			end,
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.ino",
			once = false,
			callback = function()
				vim.notify(
					"Arduino sketch — <leader>ac compile  <leader>au upload  <leader>ab both",
					vim.log.levels.INFO,
					{ title = "Arduino" }
				)
			end,
		})
	end,
}
