return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      pyright = {
        settings = {
          python = {
            venvPath = ".",
            venv = ".venv",
          },
        },
      },
    },
  },
}
