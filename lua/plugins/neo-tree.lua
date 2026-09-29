-- Per-file line counts in Neo-tree (primary file explorer).
-- Cached by path + mtime so expanding dirs stays cheap.

local line_count_cache = {}
local MAX_BYTES = 2 * 1024 * 1024

local function format_count(n)
  if n >= 1000000 then
    return string.format("%.1fM", n / 1000000)
  elseif n >= 10000 then
    return string.format("%.1fk", n / 1000)
  end
  return tostring(n)
end

local function count_lines(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
    return vim.api.nvim_buf_line_count(bufnr)
  end

  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" or stat.size > MAX_BYTES then
    return nil
  end

  local cached = line_count_cache[path]
  if cached and cached.mtime == stat.mtime.sec then
    return cached.lines
  end

  local ok, lines = pcall(function()
    local count = 0
    for _ in io.lines(path) do
      count = count + 1
    end
    return count
  end)
  if not ok then
    return nil
  end

  line_count_cache[path] = { mtime = stat.mtime.sec, lines = lines }
  return lines
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
    opts = {
      default_component_configs = {
        line_count = {
          width = 6,
          -- Low enough to show in a normal left Neo-tree sidebar.
          required_width = 36,
          highlight = "NeoTreeFileStats",
        },
      },
      filesystem = {
        components = {
          line_count = function(config, node, state)
            local width = config.width or 6

            if node:get_depth() == 1 then
              return {
                text = vim.fn.printf("%" .. width .. "s  ", "Lines"),
                highlight = "NeoTreeFileStatsHeader",
              }
            end

            if node.type ~= "file" then
              return {
                text = vim.fn.printf("%" .. width .. "s  ", "-"),
                highlight = config.highlight or "NeoTreeFileStats",
              }
            end

            local lines = count_lines(node.path)
            local text = lines and format_count(lines) or "-"
            return {
              text = vim.fn.printf("%" .. width .. "s  ", text),
              highlight = config.highlight or "NeoTreeFileStats",
            }
          end,
        },
        -- Source-specific renderer replaces the default file row entirely.
        renderers = {
          file = {
            { "indent" },
            { "icon" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                {
                  "symlink_target",
                  zindex = 10,
                  highlight = "NeoTreeSymbolicLinkTarget",
                },
                { "clipboard", zindex = 10 },
                { "bufnr", zindex = 10 },
                { "modified", zindex = 20, align = "right" },
                { "diagnostics", zindex = 20, align = "right" },
                { "git_status", zindex = 10, align = "right" },
                { "line_count", zindex = 10, align = "right" },
                { "file_size", zindex = 10, align = "right" },
                { "type", zindex = 10, align = "right" },
                { "last_modified", zindex = 10, align = "right" },
                { "created", zindex = 10, align = "right" },
              },
            },
          },
        },
      },
    },
  },
}
