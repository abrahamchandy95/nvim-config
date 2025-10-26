vim.bo.textwidth = 78
vim.wo.colorcolumn = "79"

local function get_col_limit()
  return (vim.bo.textwidth and vim.bo.textwidth > 0) and vim.bo.textwidth or 78
end

local function clangfmt_align_style()
  if vim.fn.executable("clang-format") == 1 then
    local v = vim.fn.systemlist("clang-format --version")[1] or ""
    local major = tonumber(v:match("version%s+(%d+)"))
    if major and major >= 16 then return "BlockIndent" end
  end
  return "DontAlign"
end

local STYLE = string.format(
  "{BasedOnStyle: LLVM, "
  .. "ColumnLimit: %d, "
  .. "ContinuationIndentWidth: 4, "
  .. "AlignAfterOpenBracket: %s, "
  .. "BinPackArguments: false, "
  .. "BinPackParameters: false, "
  .. "AllowAllArgumentsOnNextLine: false, "
  .. "AllowAllParametersOfDeclarationOnNextLine: false, "
  .. "PenaltyBreakBeforeFirstCallParameter: 0, "
  .. "BreakBeforeBraces: Attach}",
  get_col_limit(),
  clangfmt_align_style()
)

local function param_ranges_cpp(bufnr)
  local ok_ts, ts = pcall(require, "vim.treesitter")
  if not ok_ts then return {} end
  local parser = ts.get_parser(bufnr, "cpp")
  if not parser then return {} end

  local tree = parser:parse()[1]
  if not tree then return {} end
  local root = tree:root()

  local ok_q, q = pcall(ts.query.parse, "cpp", [[
    (parameter_list) @plist
    (argument_list)  @alist
  ]])
  if not ok_q or not q then return {} end

  local COL, ranges = get_col_limit(), {}
  for _, node in q:iter_captures(root, bufnr, 0, -1) do
    local sr, sc, er, ec = node:range()
    if sr == er then
      if (ec - sc) > COL then table.insert(ranges, { sr + 1, er + 1 }) end
    else
      table.insert(ranges, { sr + 1, er + 1 })
    end
  end

  table.sort(ranges, function(a, b) return a[1] < b[1] end)
  local merged = {}
  for _, r in ipairs(ranges) do
    if #merged == 0 or r[1] > merged[#merged][2] + 1 then
      table.insert(merged, { r[1], r[2] })
    else
      if r[2] > merged[#merged][2] then merged[#merged][2] = r[2] end
    end
  end
  return merged
end

local grp = vim.api.nvim_create_augroup("cpp.param.wrap", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grp,
  buffer = 0,
  callback = function()
    if vim.fn.executable("clang-format") ~= 1 then return end
    local ranges = param_ranges_cpp(0)
    if #ranges == 0 then return end
    local cmd = "silent keepjumps %!clang-format --style=" .. vim.fn.shellescape(STYLE)
    for _, r in ipairs(ranges) do
      cmd = cmd .. string.format(" -lines=%d:%d", r[1], r[2])
    end
    vim.cmd(cmd)
  end,
})
