-- Copyright 2025 Tanner Davison
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim",
    "ravitemer/mcphub.nvim", -- MCP integration
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
          -- TOOLS CONFIG
          tools = {
            opts = {
              auto_submit_errors = true,
              auto_submit_success = true,
              -- Auto-add the full_stack_dev tool group to every chat
              -- This gives Claude access to all file/code tools automatically
              default_tools = { "full_stack_dev" },
            },
            -- ============================================
            -- BUILT-IN TOOLS - All available tools
            -- ============================================
            -- File Operations
            ["insert_edit_into_file"] = {
              opts = {
                require_approval_before = false,
                require_confirmation_after = true,
              },
            },
            ["read_file"] = {
              opts = {
                require_approval_before = false,
              },
            },
            ["create_file"] = {
              opts = {
                require_approval_before = true, -- Ask before creating files
              },
            },
            ["delete_file"] = {
              opts = {
                require_approval_before = true, -- Always ask before deleting
              },
            },
            -- Code Analysis
            ["list_code_usages"] = {
              opts = {
                require_approval_before = false,
              },
            },
            ["grep_search"] = {
              opts = {
                require_approval_before = false,
              },
            },
            ["file_search"] = {
              opts = {
                require_approval_before = false,
              },
            },
            -- Execution
            ["cmd_runner"] = {
              opts = {
                require_approval_before = true, -- Ask before running commands
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
            ["symbols"] = {
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
          provider = "mini.diff",
        },
      },

      -- ============================================
      -- OPTS - General options
      -- ============================================
      opts = {
        send_code = true,
        log_level = "DEBUG",
      },

      -- ============================================
      -- EXTENSIONS - MCPHub integration
      -- ============================================
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools
            make_tools = true,              -- Create @server tools from MCP servers
            show_server_tools_in_chat = true,
            add_mcp_prefix_to_tool_names = false,
            show_result_in_chat = true,
            -- MCP Resources  
            make_vars = true,               -- Convert MCP resources to #variables
            -- MCP Prompts
            make_slash_commands = true,     -- Add MCP prompts as /slash commands
          },
        },
      },
    })

    -- ============================================
    -- KEYMAPS - All using <leader>k prefix
    -- ============================================
    local keymap = vim.keymap.set

    -- Main CodeCompanion keymaps
    keymap({ "n", "v" }, "<leader>kc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
    keymap({ "n", "v" }, "<leader>ka", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
    keymap("v", "<leader>ks", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to CodeCompanion" })

    -- Quick chat with current buffer context
    keymap("n", "<leader>kb", function()
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("#buffer ", true, false, true), "n", false)
      end, 200)
    end, { desc = "CodeCompanion with buffer context" })

    -- File editing helper
    keymap("n", "<leader>kf", function()
      local current_file = vim.api.nvim_buf_get_name(0)
      local relative_path = vim.fn.fnamemodify(current_file, ":~:.")
      
      if current_file == "" then
        vim.notify("No file open in current buffer", vim.log.levels.WARN)
        return
      end
      
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        local instructions = string.format([[
=== CODECOMPANION TOOLS AVAILABLE ===

BUILT-IN TOOLS:
  @insert_edit_into_file - Edit existing files
  @read_file            - Read any file
  @create_file          - Create new files  
  @delete_file          - Delete files
  @grep_search          - Search project with grep
  @file_search          - Find files by name
  @cmd_runner           - Run shell commands

MCP TOOLS (via MCPHub):
  @tavily               - Web search
  @filesystem           - File operations
  @sequentialthinking   - Step-by-step reasoning
  @browser_tools        - Browser automation

CONTEXT:
  #buffer               - Current buffer content
  /file <path>          - Load specific file
  /symbols              - LSP symbols

EXAMPLE PROMPTS:
  "#buffer @insert_edit_into_file - add error handling"
  "@tavily search for SDL2 best practices for game loops"
  "@filesystem read ~/projects/myapp/config.json"

Open MCP Hub UI: <leader>ms
Current file: %s
]], relative_path)
        
        vim.notify(instructions, vim.log.levels.INFO)
      end, 300)
    end, { desc = "Show CodeCompanion tools help" })

    -- Diagnostic fixer with context
    keymap("n", "<leader>kd", function()
      local diagnostics = vim.diagnostic.get(0)
      if #diagnostics == 0 then
        vim.notify("No diagnostics found")
        return
      end
      
      local diag_text = {}
      for _, diag in ipairs(diagnostics) do
        table.insert(diag_text, string.format("Line %d: %s", diag.lnum + 1, diag.message))
      end
      
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        local prompt = "#buffer @insert_edit_into_file - Fix these diagnostics:\n" .. table.concat(diag_text, "\n")
        vim.fn.setreg("+", prompt)
        vim.notify("Diagnostic fix prompt copied to clipboard!", vim.log.levels.INFO)
      end, 300)
    end, { desc = "Fix Diagnostics with CodeCompanion" })

    -- Inline code generation
    keymap("n", "<leader>kg", function()
      vim.ui.input({ prompt = "Generate code: " }, function(input)
        if input then
          vim.cmd("CodeCompanion " .. input)
        end
      end)
    end, { desc = "Generate Code inline" })

    -- Explain selected code
    keymap("v", "<leader>ke", ":<C-u>'<,'>CodeCompanion /explain<CR>", { desc = "Explain selected code" })

    -- Refactor selected code
    keymap("v", "<leader>kr", ":<C-u>'<,'>CodeCompanion /refactor<CR>", { desc = "Refactor selected code" })

    -- Quick agentic mode - let Claude figure out what to do
    keymap("n", "<leader>kq", function()
      vim.ui.input({ prompt = "What do you want Claude to do? " }, function(input)
        if input then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            -- Pre-fill the chat with context and the request
            local prompt = "#buffer " .. input
            vim.fn.setreg("+", prompt)
            vim.notify("Prompt copied! Paste with Ctrl+V", vim.log.levels.INFO)
          end, 300)
        end
      end)
    end, { desc = "Quick Claude request" })

    -- Search project and discuss
    keymap("n", "<leader>kp", function()
      vim.ui.input({ prompt = "Search project for: " }, function(input)
        if input then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            local prompt = "@grep_search " .. input .. " - summarize what you find"
            vim.fn.setreg("+", prompt)
            vim.notify("Search prompt copied! Paste with Ctrl+V", vim.log.levels.INFO)
          end, 300)
        end
      end)
    end, { desc = "Search project with Claude" })

    -- API key check
    vim.defer_fn(function()
      if os.getenv("ANTHROPIC_API_KEY") then
        vim.notify("CodeCompanion ready with Claude + full_stack_dev tools", vim.log.levels.INFO)
      else
        vim.notify("Set ANTHROPIC_API_KEY environment variable!", vim.log.levels.WARN)
      end
    end, 1000)
  end,
}
