# CodeCompanion + MCPHub Integration Guide

## Architecture

```
┌─────────────────────────────────────────────┐
│         YOU (Neovim User)                    │
└─────────────────┬───────────────────────────┘
                  │
                  │ <leader>kc (chat)
                  │ <leader>ka (actions)
                  ▼
┌─────────────────────────────────────────────┐
│         CodeCompanion                        │
│  - Main AI interface (Claude Sonnet)         │
│  - Built-in tools (@insert_edit_into_file)  │
│  - Context (#buffer, /file, /symbols)       │
└─────────────────┬───────────────────────────┘
                  │
                  │ MCPHub Extension
                  ▼
┌─────────────────────────────────────────────┐
│         MCPHub (port 3002)                   │
│  - MCP server orchestrator                   │
│  - Exposes active MCP tools as @tools        │
│  - Config: ~/.config/nvim/mcpservers.json5  │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────┴──────────┬──────────┐
        ▼                    ▼          ▼
  ┌──────────┐        ┌──────────┐  ┌──────────┐
  │  tavily  │        │  github  │  │  memory  │
  └──────────┘        └──────────┘  └──────────┘
      MCP                 MCP           MCP
    Server              Server        Server
```

## Active MCP Servers

These servers are currently **enabled** in `mcpservers.json5`:

| Server | Description |
|--------|-------------|
| `tavily` | Web search for current info, docs, research |
| `github` | Repos, issues, PRs, branches, file contents, search |
| `memory` | Persistent key-value memory across sessions |

### Disabled Servers (toggle in mcpservers.json5)

These exist in the config but are currently off — set `"disabled": false` to enable:

| Server | What it does |
|--------|--------------|
| `filesystem` | Read/write files under `/home/tanner` |
| `fetch` | Fetch web content and APIs as markdown |
| `browser_tools` | Browser automation and scraping |
| `figma` | Extract design specs from Figma URLs |
| `sequentialthinking` | Step-by-step reasoning scratchpad |
| `context7` | Version-specific library docs (React, SDL2, etc.) |

## Available Tools

### Built-in CodeCompanion Tools

| Tool | Approval | Description |
|------|----------|-------------|
| `@insert_edit_into_file` | After | Edit files with precision |
| `@read_file` | None | Read any workspace file |
| `@create_file` | Before | Create new files |
| `@delete_file` | Before | Delete files |
| `@cmd_runner` | Before | Run shell commands |
| `@grep_search` | None | Regex search across project |
| `@file_search` | None | Find files by name |
| `@list_code_usages` | None | Find symbol usages via LSP |

### MCP Tools (via MCPHub)

| Tool | Status | Description |
|------|--------|-------------|
| `@tavily` | ✅ Active | Web search |
| `@github` | ✅ Active | GitHub operations |
| `@memory` | ✅ Active | Persistent memory |
| `@filesystem` | ⛔ Disabled | Files outside workspace |
| `@fetch` | ⛔ Disabled | Fetch URLs as markdown |
| `@browser_tools` | ⛔ Disabled | Browser automation |
| `@figma` | ⛔ Disabled | Extract Figma designs |
| `@sequentialthinking` | ⛔ Disabled | Complex reasoning |
| `@context7` | ⛔ Disabled | Library documentation |

### Context Commands

- `#buffer` — Include current buffer content
- `/file <path>` — Load a specific file
- `/symbols` — LSP symbols in current file

## Keymaps Reference

### Main Actions

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>kc` | n/v | Toggle chat |
| `<leader>ka` | n/v | Actions menu |
| `<leader>kb` | n | Chat with buffer context |
| `<leader>ks` | v | Add selection to chat |
| `<leader>kh` | n | Show tools help |

### Quick Actions

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>kg` | n | Generate code inline |
| `<leader>kd` | n | Fix buffer diagnostics |
| `<leader>kq` | n | Quick agentic request |
| `<leader>kp` | n | Search project with Claude |
| `<leader>kw` | n | Web research via Tavily |

### Visual Mode

| Keymap | Description |
|--------|-------------|
| `<leader>ks` | Add selection to chat |
| `<leader>ke` | Explain selected code |
| `<leader>kr` | Refactor selected code |

## Usage Examples

### Basic Chat
```
<leader>kc
#buffer explain this code
```

### Web Research
```
<leader>kw → type query
-- or manually:
<leader>kc
@tavily SDL2 game loop best practices 2025 - summarize
```

### GitHub Operations
```
<leader>kc
@github list open issues in Tanner-Davison/ai-quiz-generator
```

### Fix Diagnostics
```
<leader>kd  -- auto-builds diagnostic prompt, paste into chat
```

### File Editing
```
<leader>kc
#buffer @insert_edit_into_file - add error handling to this function
```

### Enabling a Disabled Server
Edit `~/.config/nvim/mcpservers.json5` and change:
```json
"disabled": true  →  "disabled": false
```
Then restart Neovim.

## Environment Variables

Required:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

Optional (for specific MCP servers):
```bash
export TAVILY_API_KEY="your-key"             # tavily server
export GITHUB_PERSONAL_ACCESS_TOKEN="..."   # github server
export FIGMA_API_KEY="..."                  # figma server (if enabled)
```

Add to `~/.bashrc` or `~/.zshrc` and restart terminal.

## Model & Settings

- **Model**: `claude-sonnet-4-20250514`
- **Max tokens**: `8192`
- **Temperature**: `0.2`
- **Chat layout**: Vertical, 45% width

## Troubleshooting

### MCP Tools Not Appearing
1. Run `:MCPHub` to check server status
2. Check `:messages` for errors
3. Check log: `~/.local/state/nvim/mcphub.log`
4. Restart Neovim completely

### "spawn uvx ENOENT" (fetch server)
```bash
which uvx  # Should return /home/tanner/.local/bin/uvx
```
The fetch server uses the full path `/home/tanner/.local/bin/uvx` — if uvx moved, update `mcpservers.json5`.

### API Key Warning on Startup
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
# Add to ~/.bashrc or ~/.zshrc
```

### Claude Not Using a Tool
Explicitly mention it: `@tavily search for that` or `@github find that repo`
