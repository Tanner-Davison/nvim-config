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
│  - Main AI interface                         │
│  - Built-in tools (@insert_edit_into_file)  │
│  - Context (#buffer, /file, /symbols)       │
└─────────────────┬───────────────────────────┘
                  │
                  │ MCPHub Extension
                  ▼
┌─────────────────────────────────────────────┐
│         MCPHub (port 3002)                   │
│  - MCP server orchestrator                   │
│  - Exposes all MCP tools as @tools           │
│  - Manages server lifecycle                  │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────┴─────────┬─────────────┬───────────┐
        ▼                   ▼             ▼           ▼
  ┌──────────┐        ┌──────────┐  ┌──────────┐  ┌──────────┐
  │filesystem│        │  tavily  │  │  figma   │  │  fetch   │
  └──────────┘        └──────────┘  └──────────┘  └──────────┘
       MCP                MCP           MCP           MCP
     Server             Server        Server        Server
```

## What Changed

### 1. mcpservers.json5
- Added all your MCP Hub tools to CodeCompanion
- Fixed `fetch` to use full path: `/home/tanner/.local/bin/uvx`
- Configured filesystem to use `/home/tanner` as base directory
- Added Tavily (web search), Figma, browser tools, etc.

### 2. mcphub.lua
- Enabled CodeCompanion extension (was previously only for Avante)
- Set `auto_approve = true` for smoother workflow
- Added helpful keymaps and tool reference

### 3. codecompanion.lua
- Enhanced system prompt to teach Claude about MCP tools
- Maintained all your existing keymaps
- Added tool usage guidelines
- Added new keymaps for web research (`<leader>kw`)
- Added tools help (`<leader>kh`)

## How It Works

### Tool Discovery
When CodeCompanion starts:
1. MCPHub reads `mcpservers.json5`
2. MCPHub starts all MCP servers
3. MCPHub extension exposes tools to CodeCompanion
4. Claude sees both built-in and MCP tools

### Available Tools

**Built-in CodeCompanion Tools:**
- `@insert_edit_into_file` - Edit files with precision
- `@read_file` - Read any workspace file
- `@create_file` - Create new files
- `@delete_file` - Delete files
- `@grep_search` - Search with regex
- `@file_search` - Find files by name
- `@cmd_runner` - Run shell commands

**MCP Tools (via MCPHub):**
- `@filesystem` - Files outside workspace
- `@fetch` - Fetch web content/APIs
- `@tavily` - Web search
- `@browser_tools` - Browser automation
- `@figma` - Extract Figma designs
- `@sequentialthinking` - Step-by-step reasoning
- `@everything` - Fast file search
- `@memory` - Persistent memory

### Context Commands
- `#buffer` - Current buffer content
- `/file <path>` - Load specific file
- `/symbols` - LSP symbols in current file

## Usage Examples

### Basic Chat
```
<leader>kc - Open chat
Type: "#buffer explain this code"
```

### Using MCP Tools
```
<leader>kc - Open chat
Type: "@tavily latest React 19 features - summarize"
Type: "@figma extract https://figma.com/design/ABC123?node-id=1-2"
Type: "@filesystem read ~/.bashrc"
```

### Combining Tools
```
Type: "#buffer @insert_edit_into_file - add error handling @tavily search for best practices"
```

### File Editing
```
Type: "#buffer @insert_edit_into_file - convert this to TypeScript"
Type: "@read_file ../utils/helpers.ts @insert_edit_into_file - use similar patterns"
```

### Web Research
```
<leader>kw - Quick web research
Enter: "SDL2 game loop best practices"
```

### Fix Diagnostics
```
<leader>kd - Auto-generate diagnostic fix prompt
```

## Keymaps Reference

### Main Actions
- `<leader>kc` - Toggle chat
- `<leader>ka` - Actions menu
- `<leader>kb` - Chat with buffer context
- `<leader>kh` - Show tools help

### Quick Actions
- `<leader>kg` - Generate code inline
- `<leader>kd` - Fix diagnostics
- `<leader>kq` - Quick agentic request
- `<leader>kp` - Search project
- `<leader>kw` - Web research

### Visual Mode
- `<leader>ks` - Add selection to chat
- `<leader>ke` - Explain selected code
- `<leader>kr` - Refactor selected code

### MCPHub Management
- `<leader>ms` - Open MCP Hub interface
- `<leader>mt` - Show available tools

## Environment Variables

Required:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

Optional (for specific tools):
```bash
export TAVILY_API_KEY="your-key"           # For @tavily web search
export FIGMA_PERSONAL_ACCESS_TOKEN="..."  # For @figma
```

Add to `~/.bashrc` or `~/.zshrc` and restart terminal.

## Troubleshooting

### "spawn uvx ENOENT"
This should be fixed now with the full path. If it still happens:
```bash
echo $PATH  # Verify /home/tanner/.local/bin is in PATH
which uvx   # Should show /home/tanner/.local/bin/uvx
```

### Tools Not Appearing
1. Restart Neovim completely
2. Check `:MCPHub` to see server status
3. Look for errors in `:messages`
4. Check log: `~/.local/state/nvim/mcphub.log`

### Claude Not Using MCP Tools
The system prompt now explicitly teaches Claude about:
1. When to use each tool
2. How to combine tools
3. Figma URL parsing
4. Web search best practices

If Claude forgets, remind it: "Use @tavily to search for that"

## Best Practices

### When to Use MCP vs Built-in Tools

**Use Built-in Tools:**
- Editing files in current workspace
- Reading project files
- Searching within project

**Use MCP Tools:**
- Files outside workspace (`@filesystem`)
- Web research (`@tavily`)
- Fetching APIs (`@fetch`)
- Browser automation (`@browser_tools`)
- Complex reasoning (`@sequentialthinking`)

### Combining Tools Effectively

**Research + Implementation:**
```
@tavily modern React patterns 2025
@fetch https://react.dev/blog/latest
#buffer @insert_edit_into_file - apply these patterns
```

**Design to Code:**
```
@figma extract https://figma.com/design/...
@read_file src/components/Button.tsx
@insert_edit_into_file - match the Figma design
```

**Complex Problems:**
```
@sequentialthinking break down this architecture problem
@grep_search similar patterns in codebase
@insert_edit_into_file - implement the solution
```

## What's Different from Before

1. **Unified Interface**: Everything goes through CodeCompanion (no switching between Avante/CodeCompanion)
2. **More Tools**: You now have access to 8+ MCP servers through one interface
3. **Better Prompting**: Claude knows exactly when and how to use each tool
4. **Smoother Workflow**: `auto_approve = true` means fewer confirmation dialogs
5. **Tool Combinations**: Claude can chain tools intelligently

## Next Steps

1. **Restart Neovim** - Required to load new configuration
2. **Test**: `<leader>kc` then type `@tavily test search`
3. **Check Status**: `<leader>ms` to see all servers
4. **Learn**: `<leader>kh` for quick reference

## Advanced Configuration

### Adding More MCP Servers

Edit `~/.config/nvim/mcpservers.json5`:
```json
{
  "mcpServers": {
    "your_server": {
      "command": "npx",
      "args": ["-y", "@scope/your-mcp-server"],
      "env": {
        "API_KEY": "${YOUR_API_KEY}"
      }
    }
  }
}
```

Then restart Neovim. The tool will automatically appear in CodeCompanion.

### Customizing Tool Behavior

Edit `~/.config/nvim/lua/tannerdavison/plugins/mcphub.lua`:
```lua
extensions = {
  codecompanion = {
    make_tools = true,
    show_server_tools_in_chat = true,
    add_mcp_prefix_to_tool_names = false,  -- Set true for @mcp_toolname
    show_result_in_chat = false,            -- Set true to see raw results
  },
},
```

## Support

If you run into issues:
1. Check `:messages` for errors
2. Look at `~/.local/state/nvim/mcphub.log`
3. Verify MCPHub is running: `<leader>ms`
4. Test individual tools: `@toolname help`
