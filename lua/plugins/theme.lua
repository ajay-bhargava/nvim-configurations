local function system_is_dark()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not handle then
    return false
  end
  local result = handle:read("*a") or ""
  handle:close()
  return result:match("Dark") ~= nil
end

return {
  -- Tell LazyVim which colorscheme to load so it doesn't override us.
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = system_is_dark() and "catppuccin-mocha" or "catppuccin-latte"
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = system_is_dark() and "mocha" or "latte",
        background = {
          light = "latte",
          dark = "mocha",
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
        },
      })

      local current_theme = nil

      -- Detect macOS system appearance and apply the matching theme.
      local function set_theme_from_system()
        local is_dark = system_is_dark()
        local new_theme = is_dark and "catppuccin-mocha" or "catppuccin-latte"
        if new_theme == current_theme then
          return
        end
        current_theme = new_theme
        vim.o.background = is_dark and "dark" or "light"
        vim.cmd.colorscheme(new_theme)
      end

      set_theme_from_system()

      -- Re-apply after LazyVim finishes its own colorscheme setup, otherwise
      -- LazyVim's startup will override the theme we just selected.
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          current_theme = nil
          set_theme_from_system()
        end,
      })

      -- Re-check when focus returns instead of polling continuously.
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = set_theme_from_system,
      })
    end,
  },
}
