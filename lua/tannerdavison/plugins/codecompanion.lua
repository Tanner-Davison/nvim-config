-- Copyright 2025 Tanner Davison
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim",
    "ravitemer/mcphub.nvim",
  },
  config = function()
    require("codecompanion").setup({
      -- ============================================
      -- ADAPTERS
      -- ============================================
      adapters = {
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

      -- ============================================
      -- STRATEGIES (was 'interactions' pre-v13)
      -- ============================================
      strategies = {
        chat = {
          adapter = "anthropic",
          system_prompt = [[You are an expert full-stack developer. You have access to tools when the user provides them via @mentions. Only use tools that have been explicitly made available in the conversation. Be concise and precise with edits.]],
          tools = {
            opts = {
              auto_submit_errors = true,
              auto_submit_success = true,
            },
            ["insert_edit_into_file"] = {
              opts = {
                require_approval_before = false,
                require_confirmation_after = true,
              },
            },
            ["read_file"] = {
              opts = { require_approval_before = false },
            },
            ["create_file"] = {
              opts = { require_approval_before = true },
            },
            ["delete_file"] = {
              opts = { require_approval_before = true },
            },
            ["cmd_runner"] = {
              opts = { require_approval_before = true },
            },
            ["grep_search"] = {
              opts = { require_approval_before = false },
            },
            ["file_search"] = {
              opts = { require_approval_before = false },
            },
            ["list_code_usages"] = {
              opts = { require_approval_before = false },
            },
          },
          slash_commands = {
            ["buffer"] = { opts = { provider = "telescope" } },
            ["file"] = { opts = { provider = "telescope" } },
            ["symbols"] = { opts = { provider = "telescope" } },
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
      -- DISPLAY
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
            height = 0.85,
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
      -- OPTIONS
      -- ============================================
      opts = {
        send_code = true,
        log_level = "INFO",
      },

      -- ============================================
      -- MCPHUB EXTENSION
      -- ============================================
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_tools = true,
            show_server_tools_in_chat = true,
            add_mcp_prefix_to_tool_names = false,
            show_result_in_chat = true,
            make_vars = true,
            make_slash_commands = true,
          },
        },
      },
    })

    -- ============================================
    -- KEYMAPS - <leader>k prefix
    -- ============================================
    local keymap = vim.keymap.set

    -- Main actions
    keymap({ "n", "v" }, "<leader>kc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })
    keymap({ "n", "v" }, "<leader>ka", "<cmd>CodeCompanionActions<cr>", { desc = "Actions" })
    keymap("v", "<leader>ks", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to Chat" })

    -- Context shortcuts
    keymap("n", "<leader>kb", function()
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("#buffer ", true, false, true), "n", false)
      end, 200)
    end, { desc = "Chat with buffer" })

    -- Tools help
    keymap("n", "<leader>kh", function()
      vim.notify([[
=== CODECOMPANION + MCPHUB ===

Chat:  <leader>kc    Actions: <leader>ka
Buffer: <leader>kb   Help: <leader>kh

MCP Tools (@name):
  @filesystem  @fetch  @tavily  @context7
  @github  @git  @figma  @browser_tools
  @sequentialthinking  @memory  @neovim

Built-in (@name):
  @insert_edit_into_file  @read_file
  @grep_search  @file_search  @cmd_runner

Context:  #buffer  /file  /symbols
MCP Vars: #{mcp:neovim://diagnostics/buffer}

MCP Hub: <leader>ms
]], vim.log.levels.INFO)
    end, { desc = "Show tools help" })

    -- Diagnostic fixer
    keymap("n", "<leader>kd", function()
      local diagnostics = vim.diagnostic.get(0)
      if #diagnostics == 0 then
        vim.notify("No diagnostics found", vim.log.levels.INFO)
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
        vim.notify("Diagnostic prompt copied! Paste with Ctrl+V", vim.log.levels.INFO)
      end, 300)
    end, { desc = "Fix Diagnostics" })

    -- Quick actions
    keymap("n", "<leader>kg", function()
      vim.ui.input({ prompt = "Generate code: " }, function(input)
        if input then
          vim.cmd("CodeCompanion " .. input)
        end
      end)
    end, { desc = "Generate Code" })

    keymap("v", "<leader>ke", ":<C-u>'<,'>CodeCompanion /explain<CR>", { desc = "Explain code" })
    keymap("v", "<leader>kr", ":<C-u>'<,'>CodeCompanion /refactor<CR>", { desc = "Refactor code" })

    -- Agentic mode
    keymap("n", "<leader>kq", function()
      vim.ui.input({ prompt = "What should Claude do? " }, function(input)
        if input then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            local prompt = "#buffer " .. input
            vim.fn.setreg("+", prompt)
            vim.notify("Prompt ready! Paste with Ctrl+V", vim.log.levels.INFO)
          end, 300)
        end
      end)
    end, { desc = "Quick request" })

    -- Project search
    keymap("n", "<leader>kp", function()
      vim.ui.input({ prompt = "Search project: " }, function(input)
        if input then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            local prompt = "@grep_search " .. input .. " - analyze findings"
            vim.fn.setreg("+", prompt)
            vim.notify("Search prompt ready! Paste with Ctrl+V", vim.log.levels.INFO)
          end, 300)
        end
      end)
    end, { desc = "Search with Claude" })

    -- Web research
    keymap("n", "<leader>kw", function()
      vim.ui.input({ prompt = "Research: " }, function(input)
        if input then
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            local prompt = "@tavily " .. input .. " - summarize findings"
            vim.fn.setreg("+", prompt)
            vim.notify("Research prompt ready! Paste with Ctrl+V", vim.log.levels.INFO)
          end, 300)
        end
      end)
    end, { desc = "Web research" })

    -- Startup check
    vim.defer_fn(function()
      if os.getenv("ANTHROPIC_API_KEY") then
        vim.notify("✅ CodeCompanion + MCPHub ready!", vim.log.levels.INFO)
      else
        vim.notify("⚠️  Set ANTHROPIC_API_KEY environment variable", vim.log.levels.WARN)
      end
    end, 1500)
  end,
}
