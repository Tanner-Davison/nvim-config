return {
	"tpope/vim-projectionist",
	config = function()
		-- Define file relationships for different project types
		vim.g.projectionist_heuristics = {
			-- React/TypeScript projects
			["package.json"] = {
				["src/components/*.tsx"] = {
					alternate = {
						"src/components/{}.test.tsx",
						"src/components/{}.stories.tsx",
						"src/components/{}.styles.ts",
						"src/components/{}/index.ts",
					},
					type = "component",
				},
				["src/components/*.test.tsx"] = {
					alternate = "src/components/{}.tsx",
					type = "test",
				},
				["src/components/*.stories.tsx"] = {
					alternate = "src/components/{}.tsx",
					type = "story",
				},
				["src/components/*.styles.ts"] = {
					alternate = "src/components/{}.tsx",
					type = "styles",
				},
				["src/pages/*.tsx"] = {
					alternate = {
						"src/pages/{}.test.tsx",
						"src/components/{}.tsx",
					},
					type = "page",
				},
			},
			-- C++ projects
			["CMakeLists.txt|*.cpp"] = {
				["src/*.cpp"] = {
					alternate = {
						"include/{}.hpp",
						"include/{}.h",
						"src/{}.hpp",
						"src/{}.h",
					},
					type = "source",
				},
				["include/*.hpp"] = {
					alternate = {
						"src/{}.cpp",
						"tests/{}_test.cpp",
					},
					type = "header",
				},
				["include/*.h"] = {
					alternate = {
						"src/{}.cpp",
						"src/{}.c",
						"tests/{}_test.cpp",
					},
					type = "header",
				},
				["tests/*_test.cpp"] = {
					alternate = {
						"src/{}.cpp",
						"include/{}.hpp",
					},
					type = "test",
				},
				["*.cpp"] = {
					alternate = {
						"{}.hpp",
						"{}.h",
						"include/{}.hpp",
						"include/{}.h",
					},
					type = "source",
				},
				["*.hpp"] = {
					alternate = {
						"{}.cpp",
						"src/{}.cpp",
						"tests/{}_test.cpp",
					},
					type = "header",
				},
			},
		}

		-- Helper function to get alternate file path from projectionist
		local function get_alternate_path()
			-- Call projectionist's query function to get the alternate
			local result = vim.fn["projectionist#query"]("alternate")
			if vim.tbl_isempty(result) then
				return nil
			end
			
			-- The result is a list of [file, data] pairs
			-- We want the first alternate file path
			for _, item in ipairs(result) do
				local alternate_candidates = item[2]
				if type(alternate_candidates) == "table" then
					return alternate_candidates[1]  -- Return first candidate
				elseif type(alternate_candidates) == "string" then
					return alternate_candidates
				end
			end
			
			return nil
		end

		-- Helper function to create alternate file if it doesn't exist
		local function open_alternate(split_cmd)
			return function()
				-- First, try the normal projectionist command
				local cmd_map = {
					[""] = "A",
					["vsplit"] = "AV", 
					["split"] = "AS",
					["tabnew"] = "AT"
				}
				
				local proj_cmd = cmd_map[split_cmd] or "A"
				local ok = pcall(vim.cmd, proj_cmd)
				
				if ok then
					-- Successfully opened alternate file
					return
				end
				
				-- Failed - try to get the alternate path
				local alternate_path = get_alternate_path()
				
				if not alternate_path then
					vim.notify("No alternate file configured", vim.log.levels.WARN)
					return
				end
				
				-- Check if file exists
				if vim.fn.filereadable(alternate_path) == 1 then
					-- File exists, just open it
					if split_cmd == "" then
						vim.cmd("edit " .. vim.fn.fnameescape(alternate_path))
					else
						vim.cmd(split_cmd .. " " .. vim.fn.fnameescape(alternate_path))
					end
					return
				end
				
				-- File doesn't exist - ask to create
				local choice = vim.fn.confirm(
					string.format('Create "%s"?', alternate_path),
					"&Yes\n&No",
					1
				)
				
				if choice == 1 then
					-- Create parent directory if needed
					local dir = vim.fn.fnamemodify(alternate_path, ":h")
					if vim.fn.isdirectory(dir) == 0 then
						vim.fn.mkdir(dir, "p")
					end
					
					-- Open/create the file
					if split_cmd == "" then
						vim.cmd("edit " .. vim.fn.fnameescape(alternate_path))
					else
						vim.cmd(split_cmd .. " " .. vim.fn.fnameescape(alternate_path))
					end
					
					vim.notify("Created: " .. alternate_path, vim.log.levels.INFO)
				end
			end
		end

		-- Key mappings for file switching
		vim.keymap.set("n", "<leader>fa", open_alternate(""), { desc = "Switch to alternate file" })
		vim.keymap.set("n", "<leader>fv", open_alternate("vsplit"), { desc = "Switch to alternate file (vertical split)" })
		vim.keymap.set("n", "<leader>fs", open_alternate("split"), { desc = "Switch to alternate file (horizontal split)" })
		vim.keymap.set("n", "<leader>ft", open_alternate("tabnew"), { desc = "Switch to alternate file (new tab)" })
	end,
}
