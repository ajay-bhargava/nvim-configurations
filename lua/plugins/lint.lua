return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave", "BufEnter" },
  config = function()
    local lint = require("lint")
    local biome_cmd = vim.fn.executable("biome") == 1 and "biome"
      or (vim.fn.executable("biomejs") == 1 and "biomejs" or nil)

    -- Custom ty linter
    lint.linters.ty = {
      cmd = "uvx",
      args = { "ty", "check", "--output-format", "concise" },
      stdin = false,
      append_fname = true,
      stream = "stderr",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        local fname = vim.api.nvim_buf_get_name(bufnr)
        for line in output:gmatch("[^\r\n]+") do
          local file, lnum, col, severity, code, message =
            line:match("([^:]+):(%d+):(%d+): (%w+)%[([^%]]+)%]: (.+)")
          if file and file:match(vim.fn.fnamemodify(fname, ":t") .. "$") then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = tonumber(col) - 1,
              severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
              message = message,
              source = "ty",
              code = code,
            })
          end
        end
        return diagnostics
      end,
    }

    if biome_cmd then
      lint.linters.biomejs = vim.tbl_deep_extend("force", lint.linters.biomejs or {}, {
        cmd = biome_cmd,
      })
    end

    lint.linters_by_ft = biome_cmd and {
      javascript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescript = { "biomejs" },
      typescriptreact = { "biomejs" },
      -- python = { "ty" },  -- Using ty LSP instead
    } or {}

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter" }, {
      callback = function()
        local linters = lint.linters_by_ft[vim.bo.filetype]
        if linters and #linters > 0 then
          lint.try_lint(linters)
        end
      end,
    })
  end,
}
