return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    config = function()
        -- Custom highlight groups tuned to your vscode/dracula theme
        local highlights = {
            -- Headings — pink → purple → teal → yellow gradient
            { "RenderMarkdownH1",     { fg = "#FF79C6", bold = true } },
            { "RenderMarkdownH2",     { fg = "#BD93F9", bold = true } },
            { "RenderMarkdownH3",     { fg = "#67D4FF", bold = true } },
            { "RenderMarkdownH4",     { fg = "#50FA7B", bold = true } },
            { "RenderMarkdownH5",     { fg = "#F1FA8C", bold = true } },
            { "RenderMarkdownH6",     { fg = "#FFB86C", bold = true } },
            -- Heading backgrounds — subtle tinted fills
            { "RenderMarkdownH1Bg",   { bg = "#2a0a1a" } },
            { "RenderMarkdownH2Bg",   { bg = "#1a0a2a" } },
            { "RenderMarkdownH3Bg",   { bg = "#0a1824" } },
            { "RenderMarkdownH4Bg",   { bg = "#0a1a0a" } },
            { "RenderMarkdownH5Bg",   { bg = "#1a1a0a" } },
            { "RenderMarkdownH6Bg",   { bg = "#1a0f0a" } },
            -- Code blocks
            { "RenderMarkdownCode",   { bg = "#0A1824" } },
            { "RenderMarkdownCodeInline", { fg = "#67D4FF", bg = "#081016" } },
            -- Bullets
            { "RenderMarkdownBullet", { fg = "#BD93F9" } },
            -- Checkboxes
            { "RenderMarkdownChecked",   { fg = "#50FA7B" } },
            { "RenderMarkdownUnchecked", { fg = "#405779" } },
            -- Tables
            { "RenderMarkdownTableHead", { fg = "#FF79C6", bold = true } },
            { "RenderMarkdownTableRow",  { fg = "#d4d4d4" } },
            { "RenderMarkdownTableFill", { fg = "#405779" } },
            -- Horizontal rule
            { "RenderMarkdownDash",      { fg = "#405779" } },
            -- Quote blocks
            { "RenderMarkdownQuote",     { fg = "#98C379", italic = true } },
            -- Links
            { "RenderMarkdownLink",      { fg = "#67D4FF", underline = true } },
        }

        for _, hl in ipairs(highlights) do
            vim.api.nvim_set_hl(0, hl[1], hl[2])
        end

        -- Re-apply after colorscheme reload
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                for _, hl in ipairs(highlights) do
                    vim.api.nvim_set_hl(0, hl[1], hl[2])
                end
            end,
        })

        require("render-markdown").setup({
            enabled = true,
            heading = {
                enabled = true,
                sign = false, -- cleaner without sign column icons
                icons = { "❶  ", "❷  ", "❸  ", "❹  ", "❺  ", "❻  " },
                width = "full",       -- heading bg spans full line
                left_pad = 1,
                right_pad = 1,
            },
            bullet = {
                enabled = true,
                icons = { "◉", "○", "◆", "◇" },
                left_pad = 0,
                right_pad = 1,
            },
            code = {
                enabled = true,
                sign = false,
                style = "full",
                position = "left",
                language_pad = 2,
                width = "full",
                left_pad = 2,
                right_pad = 2,
                border = "thin",
            },
            dash = {
                enabled = true,
                icon = "─",
                width = "full",
            },
            checkbox = {
                enabled = true,
                unchecked = { icon = "󰄱 " },
                checked   = { icon = "󰱒 " },
            },
            quote = {
                enabled = true,
                icon = "▌",
            },
            table = {
                enabled = true,
                style = "full",
                cell = "padded",
            },
            link = {
                enabled = true,
                image = "󰥶 ",
                hyperlink = "󰌹 ",
            },
            -- Only render in normal mode so editing feels natural
            render_modes = { "n", "c" },
        })
    end,
    keys = {
        {
            "<leader>pm",
            function()
                require("render-markdown").toggle()
            end,
            desc = "Toggle Markdown Preview",
            ft = "markdown",
        },
    },
}
