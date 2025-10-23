-- 78-col visual cue
vim.bo.textwidth = 78
vim.wo.colorcolumn = "79"

-- Inline clang-format style (no .clang-format needed).
-- Prefer BlockIndent (puts ')' on its own line). Fallback to DontAlign on older versions.
local function clangfmt_align_style()
  if vim.fn.executable("clang-format") == 1 then
    local v = vim.fn.systemlist("clang-format --version")[1] or ""
    local major = tonumber(v:match("version%s+(%d+)"))
    if major and major >= 16 then
      return "BlockIndent"
    end
  end
  return "DontAlign"
end

local STYLE = string.format(
  "{BasedOnStyle: LLVM, ColumnLimit: 78, AlignAfterOpenBracket: %s, BinPackArguments: false, BinPackParameters: false, AllowAllArgumentsOnNextLine: false, AllowAllParametersOfDeclarationOnNextLine: false, BreakBeforeBraces: Attach}",
  clangfmt_align_style()
)

-- Build a list of line ranges that need rewriting, using Tree-sitter.
local function param_ranges_cpp(bufnr)
  local ok_ts, ts = pcall(require, "vim.treesitter")
  if not ok_ts then return {} end
  local parser = ts.get_parser(bufnr, "cpp")
  if not parser then return {} end
  local tree = parser:parse()[1]
  local root = tree:root()

  local Query = vim.treesitter.query
  local q = Query.parse("cpp", [[
    (parameter_list) @plist
    (argument_list)  @alist
  ]])

  local ranges = {}
  for _, node, _ in q:iter_captures(root, bufnr, 0, -1) do
    local sr, sc, er, ec = node:range() -- 0-based, end-exclusive
    local single = (sr == er)
    if single then
      -- If whole list is on one line and wider than 78 chars, mark it.
      if (ec - sc) > 78 then
        table.insert(ranges, { sr + 1, er + 1 })
      end
    else
      -- Already multi-line: reflow to block-indent so it doesn't "hang under (".
      table.insert(ranges, { sr + 1, er + 1 })
    end
  end

  -- Merge overlapping/adjacent ranges to minimize -lines flags.
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

-- Ensure our param fixing runs *after* your LSP on-save formatting.
local grp = vim.api.nvim_create_augroup("cpp.param.wrap", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = grp,
  buffer = 0,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "clangd" then return end

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = grp,
      buffer = 0,
      callback = function()
        local ranges = param_ranges_cpp(0)
        if #ranges == 0 then return end
        local cmd = "silent keepjumps %!clang-format --style=" .. vim.fn.shellescape(STYLE)
        for _, r in ipairs(ranges) do
          cmd = cmd .. string.format(" -lines=%d:%d", r[1], r[2])
        end
        vim.cmd(cmd)
      end,
    })
  end,
})
