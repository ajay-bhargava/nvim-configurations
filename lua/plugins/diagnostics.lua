return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = {
        prefix = "●",
        spacing = 2,
      },
      float = {
        border = "rounded",
        source = true,
        max_width = 80,
        wrap = true,
      },
      signs = true,
      underline = true,
    },
  },
}
