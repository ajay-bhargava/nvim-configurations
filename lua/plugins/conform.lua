return {
  "stevearc/conform.nvim",
  opts = function()
    local biome_cmd = vim.fn.executable("biome") == 1 and "biome"
      or (vim.fn.executable("biomejs") == 1 and "biomejs" or nil)
    local has_ruff = vim.fn.executable("ruff") == 1
    local formatters_by_ft = {}

    if has_ruff then
      formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
    end

    if biome_cmd then
      formatters_by_ft.javascript = { "biome" }
      formatters_by_ft.javascriptreact = { "biome" }
      formatters_by_ft.typescript = { "biome" }
      formatters_by_ft.typescriptreact = { "biome" }
      formatters_by_ft.json = { "biome" }
    end

    return {
      formatters = biome_cmd and {
        biome = {
          command = biome_cmd,
        },
      } or {},
      formatters_by_ft = formatters_by_ft,
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    }
  end,
}
