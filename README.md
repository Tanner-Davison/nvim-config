# Tanner Davison's Neovim Configuration

A comprehensive, modern Neovim configuration built with Lua and Lazy.nvim as the plugin manager. This configuration emphasizes performance, productivity, and a clean development experience.

## 🚀 Features

### Core Performance Optimizations
- **Fast startup times** with Lazy.nvim's lazy loading
- **Memory efficient** configuration with optimized settings
- **No backup/swap files** for cleaner project management
- **Custom performance tuning** for large files and complex operations

### Plugin Management
- **Lazy.nvim** as the modern plugin manager
- **Lazy loading** for optimal startup performance
- **Automatic updates** with non-intrusive notifications
- **Plugin organization** with modular structure

### Development Tools
- **LSP Integration** with comprehensive language support
- **Treesitter** for syntax highlighting and parsing
- **Telescope** for fuzzy finding and navigation
- **Git integration** with signs and diff viewing
- **Debugging support** with DAP integration
- **Code formatting** and linting

### User Interface
- **Tokyo Night** color scheme for comfortable coding
- **Custom statusline** with Lualine
- **File explorer** with nvim-tree
- **Buffer management** with bufferline
- **Terminal integration** with toggle functionality

### Code Enhancement
- **Auto-completion** with nvim-cmp
- **Snippets** support
- **Code commenting** with context-aware behavior
- **Surround operations** for text manipulation
- **Auto-pairing** of brackets and quotes
- **Indentation guides** with visual indicators

### Navigation & Productivity
- **Harpoon** for bookmarking frequently used files
- **Project navigation** with projectionist
- **Session management** with auto-session
- **Todo comments** highlighting
- **Fuzzy finding** across files, git, and more
- **Quick file switching** with buffer management

## 📁 Project Structure

```
~
├── init.lua                    # Entry point
├── lua/tannerdavison/
│   ├── core/                   # Core configuration
│   │   ├── init.lua           # Performance optimizations
│   │   ├── options.lua        # Vim options
│   │   ├── keymaps.lua      # Key mappings
│   │   ├── title.lua        # Window title customization
│   │   └── autocommands.lua  # Auto commands
│   ├── lazy.lua              # Plugin manager setup
│   └── plugins/              # Plugin configurations
│       ├── init.lua          # Base plugins
│       ├── lsp/               # LSP configurations
│       ├── colorscheme.lua    # Theme setup
│       ├── telescope.lua      # Fuzzy finder
│       ├── treesitter.lua     # Syntax highlighting
│       ├── nvim-cmp.lua       # Auto-completion
│       ├── gitsigns.lua       # Git integration
│       ├── lualine.lua        # Status line
│       ├── nvim-tree.lua      # File explorer
│       ├── bufferline.lua     # Buffer management
│       ├── harpoon.lua        # File bookmarking
│       ├── auto-session.lua   # Session management
│       ├── todo-comments.lua  # Todo highlighting
│       ├── trouble.lua        # Diagnostics viewer
│       ├── formatting.lua     # Code formatting
│       ├── linting.lua        # Code linting
│       └── [many more...]
```

## 🛠️ Installation

1. **Backup your current config** (optional but recommended):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:
   ```bash
   git clone https://github.com/your-username/nvim-config.git ~/.config/nvim
   ```

3. **Start Neovim** - Lazy.nvim will automatically install all plugins on first launch:
   ```bash
   nvim
   ```

## ⚙️ Configuration

### Customizing Options
Edit `lua/tannerdavison/core/options.lua` for general Vim settings.

### Adding Plugins
1. Create a new file in `lua/tannerdavison/plugins/`
2. Return a table with your plugin configuration
3. The plugin will be automatically loaded by Lazy.nvim

### Key Mappings
- Leader key: `Space`
- Custom keymaps are defined in `lua/tannerdavison/core/keymaps.lua`
- Plugin-specific keymaps are in their respective plugin files

### Performance Tuning
The configuration includes several performance optimizations:
- Reduced update time (50ms)
- Faster timeout settings
- Disabled backup and swap files
- Optimized syntax highlighting limits
- Lazy loading for all plugins

## 🔧 MCP Integration

This configuration includes Model Context Protocol (MCP) server configurations for enhanced AI-assisted development:

- **Browser Tools**: Web automation and browser control
- **Filesystem**: Secure file system access
- **Tavily**: Web search capabilities
- **Everything**: Comprehensive MCP server

Configuration files:
- `mcpservers.json` - Main MCP configuration
- `mcpservers.json5` - JSON5 format configuration
- `mcpservers-backup.json` - Backup configuration

## 🎯 Key Features in Detail

### LSP (Language Server Protocol)
- Automatic LSP server installation
- Support for multiple languages
- Custom keybindings for LSP actions
- Diagnostics integration with Trouble

### Treesitter
- Syntax highlighting for 100+ languages
- Incremental selection
- Text objects
- Code folding

### Telescope
- File finding with preview
- Git integration (commits, branches, status)
- Buffer management
- Live grep across project
- Custom pickers for various tasks

### Git Integration
- Gitsigns for inline git information
- Lazygit integration for git workflow
- Git-related Telescope pickers
- Conflict resolution helpers

## 🚀 Performance Highlights

- **Startup time**: Optimized for sub-100ms startup
- **Memory usage**: Efficient plugin loading strategies
- **File handling**: Optimized for large files (200+ column limit)
- **Responsiveness**: Reduced update intervals for snappier feel

## 📝 Custom Commands

The configuration includes several custom commands:
- Session management commands
- Formatting commands
- Git-related shortcuts
- Buffer management commands

## 🎨 Theming

- Primary theme: Tokyo Night
- Custom statusline with file information
- Git integration colors
- Diagnostic signs with custom icons

## 🤝 Contributing

Feel free to fork this configuration and adapt it to your needs. The modular structure makes it easy to customize specific aspects without affecting the entire configuration.

## 📄 License

This configuration is open source and available under the MIT License.

## 🔗 Related Files

- `init.lua` - Main entry point
- `lua/tannerdavison/lazy.lua` - Plugin manager configuration
- `lua/tannerdavison/core/init.lua` - Performance optimizations
- `mcpservers.json` - MCP server configurations
