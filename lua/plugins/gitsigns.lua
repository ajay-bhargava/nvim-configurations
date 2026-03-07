return {
  "lewis6991/gitsigns.nvim",
  opts = {
    linehl = true,
    word_diff = false,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)
    
    -- Set git highlight colors based on background
    local function set_git_colors()
      if vim.o.background == "light" then
        -- Light mode: use lighter pastels
        vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#d4f0d4" })      -- Light green for added
        vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#f0d4d4" })   -- Light red for deleted
        vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#f0e8d4" })   -- Light orange for modified
      else
        -- Dark mode: use dark colors
        vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1a3a1a" })      -- Green for added
        vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#3a1a1a" })   -- Red for deleted
        vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#3a2a1a" })   -- Orange for modified
      end
    end
    
    set_git_colors()
    
    -- Update colors when background changes
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = set_git_colors,
    })
  end,
}
