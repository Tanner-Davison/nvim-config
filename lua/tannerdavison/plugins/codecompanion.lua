-- Copyright 2025 Tanner Davison
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim",
  },
  config = function()
    require("codecompanion").setup({
      -- ============================================
      -- ADAPTERS - Configure your LLM connection
      -- ============================================
      adapters = {
        http = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "ANTHROPIC_API_KEY",
              },
              schema = {
                model = {
                  default = "claude-sonnet-4-20250514",
                },
                max_tokens = {
                  default = 8192,
                },
                temperature = {
                  default = 0.2,
                },
              },
            })
          end,
        },
      },

      -- ============================================
      -- INTERACTIONS - How you interact with the LLM
      -- ============================================
      interactions = {
        chat = {
          adapter = "anthropic",
          -- TOOLS CONFIG - This is the correct location!
          tools = {
            opts = {
              auto_submit_errors = true,  -- Send tool errors back to LLM automatically
              auto_submit_success = true, -- Send tool success back to LLM automatically
              -- Uncomment to auto-add tools to every chat:
              -- default_tools = { "insert_edit_into_file", "read_file", "create_file" },
            },
            -- Tool-specific settings
            ["insert_edit_into_file"] = {
              opts = {
                require_approval_before = false,  -- Don't ask before attempting edit
                require_confirmation_after = true, -- But confirm after seeing the diff
              },
            },
          },
          -- Slash commands config
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "telescope",
              },
            },
            ["file"] = {
              opts = {
                provider = "telescope",
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
        cmd = {
          adapter = "anthropic",
        },
      },

      -- ============================================
      -- DISPLAY - UI Configuration
      -- ============================================
      display = {
        action_palette = {
          width = 95,
          height = 10,
          provider = "telescope",
        },
        chat = {
          window = {
            layout = "vertical",
            width = 0.45,
            height = 0.8,
            relative = "editor",
          },
          show_token_count = true,
        },
        diff = {
          enabled = true,
          provider = "default", -- Use built-in diff
        },
      },

      -- ============================================
      -- OPTS - General options
      -- ============================================
      opts = {
        send_code = true,
        log_level = "DEBUG", -- Set to "TRACE" for maximum debugging
      },
    })

    -- ============================================
    -- KEYMAPS
    -- ============================================
    local keymap = vim.keymap.set

    -- Main CodeCompanion keymaps (using <leader>C to avoid conflicts)
    keymap({ "n", "v" }, "<leader>Cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
    keymap({ "n", "v" }, "<leader>Ce", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
    keymap("v", "<leader>Ca", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to CodeCompanion" })

    -- Quick chat with current buffer context
    keymap("n", "<leader>Cb", function()
      -- Open chat and include buffer context automatically
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        -- Type #buffer to include the current buffer
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("#buffer ", true, false, true), "n", false)
      end, 200)
    end, { desc = "CodeCompanion with buffer context" })

    -- File editing helper - shows instructions
    keymap("n", "<leader>Cf", function()
      local current_file = vim.api.nvim_buf_get_name(0)
      local relative_path = vim.fn.fnamemodify(current_file, ":~:.")
      
      if current_file == "" then
        vim.notify("No file open in current buffer", vim.log.levels.WARN)
        return
      end
      
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        local instructions = string.format([[
=== FILE EDITING GUIDE for %s ===

STEP 1: Share file context (type one of these):
  #buffer          <- Current buffer content
  /file %s         <- Load specific file

STEP 2: Request edit with @insert_edit_into_file:
  "@insert_edit_into_file - add a getRenderer() method"
  "@insert_edit_into_file - fix the bug on line 42"

EXAMPLE PROMPT:
  #buffer @insert_edit_into_file - add a destructor that cleans up SDL resources

The LLM will show you a diff before applying changes!
]], relative_path, relative_path)
        
        vim.notify(instructions, vim.log.levels.INFO)
      end, 300)
    end, { desc = "Setup file editing with CodeCompanion" })

    -- Diagnostic fixer with context
    keymap("n", "<leader>Cd", function()
      local diagnostics = vim.diagnostic.get(0)
      if #diagnostics == 0 then
        vim.notify("No diagnostics found")
        return
      end
      
      local diag_text = {}
      for _, diag in ipairs(diagnostics) do
        table.insert(diag_text, string.format("Line %d: %s", diag.lnum + 1, diag.message))
      end
      
      -- Open chat with buffer and diagnostics
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        local prompt = "#buffer @insert_edit_into_file - Fix these diagnostics:\n" .. table.concat(diag_text, "\n")
        -- Copy to clipboard for easy pasting
        vim.fn.setreg("+", prompt)
        vim.notify("Diagnostic fix prompt copied to clipboard!", vim.log.levels.INFO)
      end, 300)
    end, { desc = "Fix Diagnostics with CodeCompanion" })

    -- Project search and chat
    keymap("n", "<leader>Cs", function()
      vim.ui.input({ prompt = "Search project for: " }, function(search_term)
        if not search_term then return end
        
        local search_cmd = "rg -n --type-add 'code:*.{ts,tsx,js,jsx,cpp,h,hpp,lua}' -t code " 
          .. vim.fn.shellescape(search_term) .. " | head -20"
        local results = vim.fn.system(search_cmd)
        
        if vim.v.shell_error == 0 and results ~= "" then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            local prompt = "Search results for '" .. search_term .. "':\n```\n" .. results .. "```\n\nHelp me understand these."
            vim.fn.setreg("+", prompt)
            vim.notify("Search results copied to clipboard!", vim.log.levels.INFO)
          end, 300)
        else
          vim.notify("No results found for: " .. search_term)
        end
      end)
    end, { desc = "Search project and discuss" })

    -- Inline code generation
    keymap("n", "<leader>Cg", function()
      vim.ui.input({ prompt = "Generate code: " }, function(input)
        if input then
          vim.cmd("CodeCompanion " .. input)
        end
      end)
    end, { desc = "Generate Code inline" })

    -- API key check
    vim.defer_fn(function()
      if os.getenv("ANTHROPIC_API_KEY") then
        vim.notify("CodeCompanion ready with Claude", vim.log.levels.INFO)
      else
        vim.notify("Set ANTHROPIC_API_KEY environment variable!", vim.log.levels.WARN)
      end
    end, 1000)
  end,
}
