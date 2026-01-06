return {
  "lewis6991/gitsigns.nvim",
  opts = {
    linehl = true,
    word_diff = false,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)
    -- Full line background colors
    vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1a3a1a" })      -- Green for added
    vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#3a1a1a" })   -- Red for deleted
    vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#3a2a1a" })   -- Orange for modified
  end,
}
