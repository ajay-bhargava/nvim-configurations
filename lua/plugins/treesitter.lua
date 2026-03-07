return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}

    local parsers = {
      "bash",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    }

    for _, parser in ipairs(parsers) do
      if not vim.tbl_contains(opts.ensure_installed, parser) then
        table.insert(opts.ensure_installed, parser)
      end
    end

    opts.auto_install = true
  end,
}
