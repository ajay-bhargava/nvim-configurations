return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = { preset = "right", preview = false },
          filter = {
            filter = function(item)
              return not item.path:match("%.test%.ts$")
            end,
          },
        },
      },
    },
  },
  -- `init` runs at startup (before UIEnter), so this autocmd is registered in time
  -- to catch the dashboard that Snacks opens synchronously on UIEnter. (Putting it
  -- in `autocmds.lua` doesn't work — that file is loaded on `VeryLazy`, which fires
  -- *after* UIEnter.)
  init = function()
    -- Auto-open Neo-tree alongside the Snacks dashboard.
    -- `action = "show"` opens without stealing focus (cursor stays on the dashboard).
    -- `once = true` so it only fires on the first dashboard open — subsequent dashboard
    -- reopens (e.g., after closing the last buffer via the BufDelete autocmd in
    -- `config/autocmds.lua`) preserve the user's Neo-tree state.
    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardOpened",
      once = true,
      callback = function()
        pcall(function()
          require("neo-tree.command").execute({
            source = "filesystem",
            position = "left",
            action = "show",
            toggle = false,
          })
        end)
      end,
    })
  end,
}
