# Neovim Configuration

Your gateway to a highly customized, lightning-fast editor experience. Built on the solid foundation of [LazyVim](https://www.lazyvim.org/), powered by lazy.nvim, and loaded with a thoughtfully curated arsenal of development tools.

## Quick Start

### Prerequisites

- Neovim >= 0.9.0
- Git

### Installation

Clone this repo to your Neovim config directory:

```bash
git clone https://github.com/ajay-bhargava/nvim-configurations ~/.config/nvim
```

Fire up Neovim and watch the magic happen:

```bash
nvim
```

lazy.nvim automatically handles the rest—downloading and installing all plugins on first launch.

## What's Inside

```
lua/
├── config/
│   ├── autocmds.lua    # Autocommands - make Neovim dance to your tune
│   ├── keymaps.lua     # Custom keybindings - your personal keyboard shortcuts
│   ├── lazy.lua        # lazy.nvim bootstrap and setup
│   └── options.lua     # Neovim settings - fine-tune every detail
└── plugins/
    ├── amp.lua         # Amp integration - seamless AI assistance
    ├── blink.lua       # Blink completion - intelligent code completion
    ├── diffview.lua    # Git diff viewer - visualize changes at a glance
    ├── example.lua     # Example plugin configuration - learn by example
    ├── gitsigns.lua    # Git signs in gutter - track changes inline
    └── telescope.lua   # Fuzzy finder - find anything, instantly
```

## Configuration

### Editor Settings

Absolute line numbers by default. Tweak in `lua/config/options.lua`:

```lua
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = false -- Disable relative numbers
```

Prefer relative numbers? Flip the switch.

### Smart Plugin Loading

Plugins live in `lua/plugins/` and are managed by lazy.nvim. Each file returns a plugin spec table that lazy.nvim loads and configures on demand.

### Key Features

- **Plugin Management** — Automatic updates with periodic checks. Set it and forget it.
- **Color Scheme** — GitHub theme with automatic light/dark mode switching based on system appearance
- **Git Integration** — Signs in the gutter + diff viewing to track changes like a pro
- **Completion** — Blink completion engine for fast, intelligent code completion
- **Fuzzy Finding** — Telescope for searching files and text at lightning speed
- **Amp Integration** — Built-in support for Amp editor features

## Customization

### Adding Plugins

Create a new file in `lua/plugins/` following the lazy.nvim spec format:

```lua
return {
  {
    "plugin-author/plugin-name",
    -- your plugin configuration here
  }
}
```

### Custom Keybindings

Edit `lua/config/keymaps.lua` to add your own keyboard shortcuts.

### Autocommands

Add custom autocommands in `lua/config/autocmds.lua` to automate repetitive tasks.

## License

See LICENSE file for details.

## References

- [LazyVim Documentation](https://www.lazyvim.org/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Neovim Documentation](https://neovim.io/doc/user/)
