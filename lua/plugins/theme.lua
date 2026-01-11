return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        -- theme configuration here
      })
      
      local current_theme = nil
      
      -- Detect system appearance and set theme
      local function set_theme_from_system()
        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        local result = handle:read("*a")
        handle:close()
        
        local new_theme = result:match("Dark") and "github_dark_high_contrast" or "github_light_high_contrast"
        
        if new_theme ~= current_theme then
          current_theme = new_theme
          vim.cmd("colorscheme " .. new_theme)
        end
      end
      
      set_theme_from_system()
      
      -- Poll system appearance every 1 second
      local timer = vim.uv.new_timer()
      if timer then
        timer:start(1000, 1000, vim.schedule_wrap(set_theme_from_system))
      end
    end,
  }
}
