-- Copyright 2026 Tanner Davison
-- claudecode.nvim: Native Neovim IDE integration for Claude Code CLI
-- Speaks the same WebSocket + MCP protocol as the official VS Code / JetBrains extensions.
-- Requires: Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`) and snacks.nvim.
return {
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim", -- terminal + input pickers
  },
  cmd = {
    "ClaudeCode",
    "ClaudeCodeSend",
    "ClaudeCodeFocus",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeAdd",
  },
  opts = {
    -- Auto-start the WS server when Neovim launches so `claude` in an
    -- external terminal (tmux pane, wezterm split, etc.) picks up the
    -- editor context immediately.
    auto_start = true,

    -- Terminal provider: snacks looks best and we already use it heavily.
    terminal = {
      provider = "snacks",
      split_side = "right",
      split_width_percentage = 0.40,
      auto_close = false, -- keep the pane around so we can scroll history
    },

    -- Diff review behavior. Native Neovim diff windows; accept/deny with commands or keymaps below.
    diff_opts = {
      auto_close_on_accept = true,
      show_diff_stats = true,
      vertical_split = true,
      open_in_current_tab = true,
    },
  },

  -- Keymaps under <leader>a  (a = "assistant" / Claude Code)
  -- Chosen so as not to collide with <leader>k (CodeCompanion) or <leader>m (mcphub).
  keys = {
    { "<leader>a",  nil,                              desc = "AI / Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude session" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last Claude session" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer to Claude" },

    -- Send visual selection as context (works in visual mode too)
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = { "v" },      desc = "Send selection to Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = { "n" },      desc = "Send line to Claude" },

    -- Diff review
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
    { "<leader>aX", "<cmd>ClaudeCodeCloseAllDiffs<cr>", desc = "Close all pending diffs" },

    -- Add file to context from nvim-tree / snacks explorer
    { "<leader>aT", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Add tree node to Claude",  ft = { "NvimTree", "snacks_picker_list" } },
  },
}
