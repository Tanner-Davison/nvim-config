-- Copyright 2025 Tanner Davison
-- Simple Claude integration that actually works
return {
  "MunifTanjim/nui.nvim", -- We'll build on this for UI
  config = function()
    local Popup = require("nui.popup")
    local event = require("nui.utils.autocmd").event
    
    -- Simple Claude API caller
    local function call_claude(prompt, callback)
      local api_key = os.getenv("ANTHROPIC_API_KEY")
      if not api_key then
        vim.notify("ANTHROPIC_API_KEY not set", vim.log.levels.ERROR)
        return
      end
      
      local curl_cmd = {
        "curl",
        "-s",
        "-X", "POST",
        "https://api.anthropic.com/v1/messages",
        "-H", "Content-Type: application/json",
        "-H", "x-api-key: " .. api_key,
        "-H", "anthropic-version: 2023-06-01",
        "-d", vim.json.encode({
          model = "claude-3-5-sonnet-20241022",
          max_tokens = 4000,
          temperature = 0.2,
          messages = {{
            role = "user",
            content = prompt
          }}
        })
      }
      
      vim.fn.jobstart(curl_cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            local response_text = table.concat(data, "\n")
            local ok, response = pcall(vim.json.decode, response_text)
            if ok and response.content and response.content[1] then
              callback(response.content[1].text)
            else
              vim.notify("Claude API error: " .. response_text, vim.log.levels.ERROR)
            end
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            vim.notify("Claude API error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
          end
        end
      })
    end
    
    -- Show Claude response in a popup
    local function show_claude_response(response)
      local popup = Popup({
        position = "50%",
        size = {
          width = "80%",
          height = "60%",
        },
        enter = true,
        focusable = true,
        zindex = 50,
        relative = "editor",
        border = {
          padding = {
            top = 2,
            bottom = 2,
            left = 3,
            right = 3,
          },
          style = "rounded",
          text = {
            top = " Claude Response ",
            top_align = "center",
          },
        },
        win_options = {
          winblend = 10,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      })
      
      -- Set content
      local lines = vim.split(response, "\n")
      vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
      vim.api.nvim_buf_set_option(popup.bufnr, "filetype", "markdown")
      
      -- Mount the popup
      popup:mount()
      
      -- Close with q or Escape
      popup:map("n", "q", function()
        popup:unmount()
      end, { noremap = true })
      
      popup:map("n", "<Esc>", function()
        popup:unmount()
      end, { noremap = true })
    end
    
    -- Get input from user and call Claude
    local function claude_chat()
      vim.ui.input({ prompt = "Ask Claude: " }, function(input)
        if input and input ~= "" then
          vim.notify("Asking Claude...", vim.log.levels.INFO)
          call_claude(input, show_claude_response)
        end
      end)
    end
    
    -- Keymaps using <leader>k* (conflict-free)
    vim.keymap.set({ "n", "v" }, "<leader>kc", claude_chat, { desc = "Chat with Claude" })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim"
  }
}