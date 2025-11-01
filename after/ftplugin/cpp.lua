-- after/ftplugin/cpp.lua

-- ===== Buffer-local editor settings (what =G uses) =====
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.textwidth = 78
vim.wo.colorcolumn = "79"

-- ===== Helpers =====
local function cf_major()
  local v = vim.fn.systemlist("clang-format --version")[1] or ""
  return tonumber(v:match("version%s+(%d+)")) or 0
end

local function get_col_limit()
  return (vim.bo.textwidth and vim.bo.textwidth > 0) and vim.bo.textwidth
    or 78
end

local function align_after_open_bracket()
  -- BlockIndent (clang-format ≥16) puts the closing ')' on its own line.
  -- Fall back to AlwaysBreak on older versions.
  return (cf_major() >= 16) and "BlockIndent" or "AlwaysBreak"
end

local function build_style()
  -- Only widely-supported options to avoid version errors.
  return string.format(
    "{BasedOnStyle: LLVM, "
      .. "IndentWidth: 4, TabWidth: 4, UseTab: Never, "
      .. "ColumnLimit: %d, ContinuationIndentWidth: 4, "
      .. "AlignAfterOpenBracket: %s, "
      .. "BinPackArguments: false, BinPackParameters: false, "
      .. "AllowAllArgumentsOnNextLine: true, "
      .. "AllowAllParametersOfDeclarationOnNextLine: true, "
      .. "IndentWrappedFunctionNames: true, "
      .. "ConstructorInitializerAllOnOneLineOrOnePerLine: true, "
      .. "BreakConstructorInitializers: BeforeColon, "
      .. "ConstructorInitializerIndentWidth: 4, "
      .. "PenaltyBreakBeforeFirstCallParameter: 0, "
      .. "BreakBeforeBraces: Attach}",
    get_col_limit(),
    align_after_open_bracket()
  )
end

-- ===== Format-on-save with clang-format (full buffer) =====
local grp = vim.api.nvim_create_augroup("cpp.clangformat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grp,
  buffer = 0,
  callback = function()
    if vim.fn.executable("clang-format") ~= 1 then
      return
    end
    local STYLE = build_style()
    vim.cmd(
      "silent keepjumps %!clang-format --style=" .. vim.fn.shellescape(STYLE)
    )
  end,
})

-- Optional: manual command you can call any time
vim.api.nvim_buf_create_user_command(0, "CxxFormat", function()
  if vim.fn.executable("clang-format") ~= 1 then
    return
  end
  local STYLE = build_style()
  vim.cmd(
    "silent keepjumps %!clang-format --style=" .. vim.fn.shellescape(STYLE)
  )
end, {})
