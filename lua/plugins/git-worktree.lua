return {
  {
    "ThePrimeagen/git-worktree.nvim",
    event = "VeryLazy",
    config = function()
      require("git-worktree").setup()
      pcall(function()
        require("telescope").load_extension("git_worktree")
      end)
    end,
  }
}
