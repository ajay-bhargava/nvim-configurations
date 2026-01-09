-- Auto-activate Python venv if it exists
if vim.fn.isdirectory(".venv") == 1 then
  vim.fn.system("source .venv/bin/activate")
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
