-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Git worktree
vim.keymap.set("n", "<leader>gw", "<cmd>Telescope git_worktree<CR>", { noremap = true, silent = true })
