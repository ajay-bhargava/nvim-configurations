-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Autosave on focus lost or buffer leave
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  command = "silent! wa",
})

-- Autoformat JSON when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*.json",
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
      return
    end

    require("conform").format({
      bufnr = args.buf,
      async = true,
      quiet = true,
      lsp_fallback = true,
      undojoin = true,
    })
  end,
})

-- Add OpenAI model indicator to statusline
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStatusline",
  callback = function()
    local model = vim.g.completion_model or "gpt-4o-mini"
    -- Abbreviate for statusline
    local abbrev = model:gsub("gpt%-", ""):gsub("%-mini", "m")
    vim.g.ai_model_status = "🤖 " .. abbrev
  end,
})

-- Return to the Snacks dashboard when the last real file buffer is closed.
-- `Snacks.bufdelete()` (mapped to `<leader>bd` by LazyVim) leaves an empty scratch
-- buffer behind instead of reopening the dashboard. This autocmd converts that
-- scratch into the dashboard so closing the last file lands you back on the
-- dashboard, with Neo-tree (if open) still visible on the left and `<leader>fe`
-- able to toggle it.
--
-- Note: the *startup* auto-open of Neo-tree alongside the dashboard lives in
-- `plugins/snacks.lua`'s `init`, because this file is loaded on `VeryLazy` (which
-- fires after UIEnter, so an autocmd registered here would miss the startup
-- dashboard open).
local function find_inline_non_neotree_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.bo[b].filetype ~= "neo-tree" and vim.api.nvim_win_get_config(w).relative == "" then
      return w
    end
  end
end

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    -- Don't reopen when the dashboard itself is being closed
    if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == "snacks_dashboard" then
      return
    end
    vim.schedule(function()
      -- Skip if a dashboard is already visible somewhere
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].filetype == "snacks_dashboard" then
          return
        end
      end
      -- Skip if a real file buffer still exists (buflisted, normal buftype, has a path)
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_loaded(b)
          and vim.bo[b].buflisted
          and vim.bo[b].buftype == ""
          and vim.api.nvim_buf_get_name(b) ~= ""
        then
          return
        end
      end
      -- Pick a non-neo-tree, non-floating window to host the dashboard so Neo-tree
      -- stays visible alongside; fall back to a float if none exists.
      local target_win = find_inline_non_neotree_win()
      if not target_win then
        Snacks.dashboard.open()
        return
      end
      vim.api.nvim_set_current_win(target_win)
      pcall(function()
        Snacks.dashboard.open({ win = 0, buf = 0 })
      end)
    end)
  end,
})
