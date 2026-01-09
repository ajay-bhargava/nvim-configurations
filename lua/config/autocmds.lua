-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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
