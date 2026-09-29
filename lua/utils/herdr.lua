local M = {}

M.config = {
  direction = "down",
  ratio = 0.5,
  focus = true,
}

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = "Herdr" })
  end)
end

local function is_absolute(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

local function normalize_path(path, cwd)
  if not path or path == "" then
    return nil
  end

  if cwd and not is_absolute(path) then
    path = cwd .. "/" .. path
  end

  return vim.fn.fnamemodify(path, ":p")
end

local function item_path(item)
  if not item then
    return nil
  end

  if item.file then
    return item.file
  end
  if item.path then
    return item.path
  end
  if item.filename then
    return item.filename
  end
  if item.value and (vim.fn.filereadable(item.value) == 1 or vim.fn.isdirectory(item.value) == 1) then
    return item.value
  end
  if item.buf and vim.api.nvim_buf_is_valid(item.buf) then
    local name = vim.api.nvim_buf_get_name(item.buf)
    if name ~= "" then
      return name
    end
  end
  if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
    local name = vim.api.nvim_buf_get_name(item.bufnr)
    if name ~= "" then
      return name
    end
  end
end

local function item_position(item)
  if not item then
    return nil, nil
  end

  local line = item.lnum or item.line
  local col = item.col

  if item.pos then
    line = line or item.pos[1]
    -- Snacks picker positions use Neovim API columns (0-based), while
    -- `cursor()` expects a 1-based column.
    col = col or (item.pos[2] and item.pos[2] + 1)
  end

  return line, col
end

local function build_nvim_command(path, opts)
  opts = opts or {}

  local nvim = opts.nvim or vim.v.progpath or "nvim"
  local cmd = vim.fn.shellescape(nvim)

  local line = tonumber(opts.line)
  if line and line > 0 then
    local col = tonumber(opts.col) or 1
    cmd = cmd .. " +" .. vim.fn.shellescape(("call cursor(%d,%d)"):format(line, col))
  end

  return cmd .. " -- " .. vim.fn.shellescape(path)
end

local function run(args)
  local result = vim.system(args, { text = true }):wait()
  if result.code ~= 0 then
    return nil, result.stderr ~= "" and result.stderr or result.stdout
  end

  local ok, decoded = pcall(vim.json.decode, result.stdout)
  if not ok then
    return nil, "Invalid JSON returned by Herdr"
  end

  return decoded
end

local function focus_arg(args, focus)
  table.insert(args, focus == false and "--no-focus" or "--focus")
end

local function find_tab_pane(tab_id, workspace)
  local args = { "herdr", "pane", "list" }
  if workspace and workspace ~= "" then
    vim.list_extend(args, { "--workspace", workspace })
  end

  local decoded, err = run(args)
  if not decoded then
    return nil, err
  end

  for _, pane in ipairs(decoded.result and decoded.result.panes or {}) do
    if pane.tab_id == tab_id then
      return pane.pane_id
    end
  end

  return nil, "Could not find the new Herdr tab's pane"
end

local function create_tab(opts)
  local workspace = opts.workspace or vim.env.HERDR_WORKSPACE_ID
  local args = { "herdr", "tab", "create", "--cwd", opts.cwd or vim.fn.getcwd() }
  if workspace and workspace ~= "" then
    vim.list_extend(args, { "--workspace", workspace })
  end
  if opts.tab_label then
    vim.list_extend(args, { "--label", opts.tab_label })
  end
  focus_arg(args, opts.focus)

  local decoded, err = run(args)
  if not decoded then
    return nil, nil, err
  end

  local tab = decoded.result and decoded.result.tab or {}
  local tab_id = tab.tab_id or (decoded.result and decoded.result.tab_id)
  if not tab_id then
    return nil, nil, "Could not read the new Herdr tab id"
  end

  local root_pane = decoded.result and decoded.result.root_pane or {}
  local pane_id = root_pane.pane_id or tab.pane_id or tab.active_pane_id
  if not pane_id then
    pane_id, err = find_tab_pane(tab_id, workspace)
  end

  return tab_id, pane_id, err
end

local function split_pane(pane_id, opts)
  local args = {
    "herdr",
    "pane",
    "split",
    "--pane",
    pane_id,
    "--direction",
    opts.direction,
    "--ratio",
    tostring(opts.ratio),
    "--cwd",
    opts.cwd or vim.fn.getcwd(),
  }
  focus_arg(args, opts.focus)

  local decoded, err = run(args)
  if not decoded then
    return nil, err
  end

  local pane = decoded.result and decoded.result.pane
  return pane and pane.pane_id, pane and nil or "Could not read new Herdr pane id"
end

local function open_in_pane(pane_id, path, opts)
  local result = vim.system({ "herdr", "pane", "run", pane_id, build_nvim_command(path, opts) }, { text = true }):wait()
  if result.code ~= 0 then
    notify(("Failed to open file in Herdr pane:\n%s"):format(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.available()
  return vim.fn.executable("herdr") == 1 and (vim.env.HERDR_ENV == "1" or vim.env.HERDR_PANE_ID ~= nil)
end

function M.open_file(path, opts)
  opts = vim.tbl_deep_extend("force", M.config, opts or {})
  path = normalize_path(path, opts.cwd)

  if not path then
    notify("No file path to open", vim.log.levels.WARN)
    return false
  end

  if vim.fn.isdirectory(path) == 1 then
    notify("Not opening directory in a Herdr pane: " .. path, vim.log.levels.WARN)
    return false
  end

  if not M.available() then
    if opts.fallback == false then
      notify("Herdr is not available", vim.log.levels.WARN)
      return false
    end

    vim.cmd.edit(vim.fn.fnameescape(path))
    return true
  end

  local pane_id
  if opts.open_in_pane then
    local source_pane = opts.pane or vim.env.HERDR_PANE_ID
    if not source_pane then
      notify("No current Herdr pane to split", vim.log.levels.ERROR)
      return false
    end

    local err
    pane_id, err = split_pane(source_pane, opts)
    if not pane_id then
      notify(("Failed to split Herdr pane:\n%s"):format(err or "Unknown error"), vim.log.levels.ERROR)
      return false
    end
  else
    local _, new_pane_id, err = create_tab(opts)
    if not new_pane_id then
      notify(("Failed to create Herdr tab:\n%s"):format(err or "Unknown error"), vim.log.levels.ERROR)
      return false
    end
    pane_id = new_pane_id
  end

  return open_in_pane(pane_id, path, opts)
end

function M.open_current_file(opts)
  opts = opts or {}

  local path = vim.api.nvim_buf_get_name(0)
  local cursor = vim.api.nvim_win_get_cursor(0)

  opts.line = opts.line or cursor[1]
  opts.col = opts.col or (cursor[2] + 1)

  return M.open_file(path, opts)
end

function M.open_item(item, opts)
  opts = opts or {}

  local line, col = item_position(item)
  opts.line = opts.line or line
  opts.col = opts.col or col

  return M.open_file(item_path(item), opts)
end

return M
