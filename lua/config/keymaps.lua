-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy diagnostics on current line to clipboard
vim.keymap.set("n", "dy", function()
  local diags = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if #diags > 0 then
    local msgs = vim.tbl_map(function(d) return d.message end, diags)
    vim.fn.setreg("+", table.concat(msgs, "\n"))
    vim.notify("Copied " .. #diags .. " diagnostic(s)")
  else
    vim.notify("No diagnostics on this line")
  end
end, { desc = "Yank diagnostics to clipboard" })

-- Dashboard
-- Open in the current window (not a float) so Neo-tree remains visible on the left
-- and `<leader>fe` can still toggle it. From a Neo-tree window, fall back to a float
-- to avoid replacing the explorer.
vim.keymap.set("n", "<leader>D", function()
  if vim.bo.filetype == "neo-tree" then
    Snacks.dashboard.open()
    return
  end
  Snacks.dashboard.open({ win = 0 })
end, { desc = "Dashboard" })

-- Git worktree
vim.keymap.set("n", "<leader>gw", "<cmd>Telescope git_worktree<CR>", { noremap = true, silent = true })

-- Herdr
local function herdr_open_current(opts)
  if vim.bo.filetype == "neo-tree" then
    local state = require("neo-tree.sources.manager").get_state("filesystem", nil, vim.api.nvim_get_current_win())
    local node = state and state.tree and state.tree:get_node()
    if not node or node.type == "directory" then
      vim.notify("Select a file in Neo-tree first", vim.log.levels.WARN)
      return
    end
    require("utils.herdr").open_file(node.path, opts)
    return
  end

  require("utils.herdr").open_current_file(opts)
end

local function herdr_open(args, opts)
  opts = opts or {}
  if args.args == "" then
    herdr_open_current(opts)
    return
  end

  opts.line = vim.fn.line(".")
  opts.col = vim.fn.col(".")
  require("utils.herdr").open_file(args.args, opts)
end

vim.api.nvim_create_user_command("HerdrOpen", function(args)
  herdr_open(args)
end, { nargs = "?", complete = "file", desc = "Open file in a new Herdr tab" })

vim.api.nvim_create_user_command("HerdrOpenRight", function(args)
  herdr_open(args, { direction = "right", open_in_pane = true })
end, { nargs = "?", complete = "file", desc = "Open file in a Herdr vertical pane" })

vim.keymap.set("n", "<leader>hO", function()
  herdr_open_current({ open_in_pane = true })
end, { desc = "Open file in Herdr horizontal pane" })

vim.keymap.set("n", "<leader>hV", function()
  herdr_open_current({ direction = "right", open_in_pane = true })
end, { desc = "Open file in Herdr vertical pane" })
