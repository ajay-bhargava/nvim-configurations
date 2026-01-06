# Neovim Configuration

A customized Neovim setup built on [LazyVim](https://www.lazyvim.org/), featuring plugin management with lazy.nvim and a curated set of tools for development.

## Quick Start

### Prerequisites

- Neovim >= 0.9.0
- Git

### Installation

Clone this repository to your Neovim config directory:

```bash
git clone https://github.com/ajay-bhargava/nvim-configurations ~/.config/nvim
```

Launch Neovim and lazy.nvim will automatically download and install all plugins:

```bash
nvim
```

## Project Structure

```
lua/
├── config/
│   ├── autocmds.lua    # Autocommands
│   ├── keymaps.lua     # Custom keybindings
│   ├── lazy.lua        # lazy.nvim bootstrap and setup
│   └── options.lua     # Neovim settings
└── plugins/
    ├── amp.lua         # Amp integration
    ├── blink.lua       # Blink completion
    ├── diffview.lua    # Git diff viewer
    ├── example.lua     # Example plugin configuration
    ├── gitsigns.lua    # Git signs in gutter
    └── telescope.lua   # Fuzzy finder
```

## Configuration

### Editor Settings

The configuration uses absolute line numbers by default. Adjust in `lua/config/options.lua`:

```lua
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = false -- Disable relative numbers
```

### Lazy Loading

Plugins are managed through lazy.nvim with specifications in `lua/plugins/`. Each plugin file returns a plugin spec table for lazy.nvim to load and configure.

### Key Features

- **Plugin Management**: Automatic plugin updates with periodic checks
- **Color Scheme**: TokyoNight as default with Habamax fallback
- **Git Integration**: Signs in gutter and diff viewing
- **Completion**: Blink completion engine
- **Fuzzy Finding**: Telescope for file and text search
- **Amp Integration**: Support for Amp editor features

## Customization

### Adding Plugins

Create a new file in `lua/plugins/` following the lazy.nvim spec format:

```lua
return {
  {
    "plugin-author/plugin-name",
    -- plugin configuration
  }
}
```

### Custom Keybindings

Edit `lua/config/keymaps.lua` to add your keybindings.

### Autocommands

Add custom autocommands in `lua/config/autocmds.lua`.

## License

See LICENSE file for details.

## References

- [LazyVim Documentation](https://www.lazyvim.org/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Neovim Documentation](https://neovim.io/doc/user/)
