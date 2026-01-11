return {
  {
    "ThePrimeagen/git-worktree.nvim",
    event = "VeryLazy",
    config = function()
      require("git-worktree").setup()
    end,
  }
}
