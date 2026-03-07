return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = function(_, opts)
    local has_ty = vim.fn.executable("ty") == 1

    opts.servers = opts.servers or {}
    -- Fall back to pyright when ty is not installed.
    opts.servers.pyright = vim.tbl_deep_extend("force", {
      settings = {
        python = {
          venvPath = ".",
          venv = ".venv",
        },
      },
    }, opts.servers.pyright or {})
    opts.servers.pyright.enabled = not has_ty
    opts.servers.ty = has_ty and (opts.servers.ty or {}) or { enabled = false }
  end,
}
