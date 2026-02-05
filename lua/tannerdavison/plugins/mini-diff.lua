-- Copyright 2025 Tanner Davison
-- mini.diff - Inline diff visualization
return {
  "echasnovski/mini.diff",
  version = false,
  event = "VeryLazy",
  config = function()
    -- Set up clear highlight colors for diffs
    -- Green for additions, Red for deletions, Yellow/Orange for changes
    vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = "#00ff00", bold = true })      -- Bright green
    vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = "#ffaa00", bold = true })   -- Orange
    vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = "#ff0000", bold = true })   -- Bright red
    
    -- Overlay colors (for inline text highlighting)
    vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { bg = "#1e3a1e" })      -- Dark green background
    vim.api.nvim_set_hl(0, "MiniDiffOverChange", { bg = "#3a3a1e" })   -- Dark yellow background
    vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { bg = "#3a1e1e" })   -- Dark red background
    vim.api.nvim_set_hl(0, "MiniDiffOverContext", { bg = "#2a2a2a" })  -- Subtle gray for context

    require("mini.diff").setup({
      -- Use default source (git)
      source = nil,
      
      -- Delay for updating diff
      delay = {
        text_change = 200,
      },
      
      -- Visualization options
      view = {
        style = "sign", -- 'sign' or 'number'
        signs = {
          add = "▎",
          change = "▎",
          delete = "▁",
        },
        priority = 199,
      },
      
      -- Mappings
      mappings = {
        apply = "gh",   -- Apply hunk
        reset = "gH",   -- Reset hunk
        textobject = "gh", -- Hunk textobject
        goto_first = "[H",
        goto_prev = "[h",
        goto_next = "]h",
        goto_last = "]H",
      },
    })
  end,
}
