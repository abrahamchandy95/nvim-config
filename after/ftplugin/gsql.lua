-- after/ftplugin/gsql.lua (minimal + safe)
-- Purpose: 78-col textwidth, 4-space indentation, block indent for GSQL
-- NOTE: This version avoids any fancy API calls or curly-brace gotchas.

-- === Basics ===
vim.bo.textwidth     = 78
vim.wo.wrap          = false
vim.bo.expandtab     = true
vim.bo.shiftwidth    = 4
vim.bo.tabstop       = 4
vim.bo.softtabstop   = 4
vim.bo.commentstring = '// %s'

-- Disable conflicting indent engines
vim.bo.cindent       = false
vim.bo.smartindent   = false
vim.bo.autoindent    = true

-- === Indentation ===
-- Python-like block indent inside {...} and during multi-line
-- CREATE QUERY (...) signatures until the opening '{'.
if _G.GSQLIndent == nil then
  function _G.GSQLIndent()
    local sw   = (vim.bo.shiftwidth > 0) and vim.bo.shiftwidth or 4
    local lnum = vim.v.lnum
    if lnum <= 1 then return 0 end

    local cur   = vim.fn.getline(lnum)
    local prevn = vim.fn.prevnonblank(lnum - 1)
    if prevn == 0 then return 0 end
    local prev = vim.fn.getline(prevn)

    local base = vim.fn.indent(prevn)

    -- Dedent if current line starts with '}'
    if cur:match('^%s*%}') then
      return math.max(base - sw, 0)
    end

    -- If previous ends with '{', indent one level
    if prev:match('%{%s*$') then
      return base + sw
    end

    -- If previous looks like a CREATE QUERY header without '{', indent
    if prev:match('^%s*CREATE%s+QUERY') and not prev:match('%{') then
      return base + sw
    end

    return base
  end
end

vim.bo.indentexpr = 'v:lua.GSQLIndent()'
-- Keep indentkeys conservative (recalc on braces)
vim.cmd('setlocal indentkeys=0{,0}')

-- Optional: quick formatter for the whole buffer
if vim.api and vim.api.nvim_buf_create_user_command then
  vim.api.nvim_buf_create_user_command(0, 'GSQLFormat', function()
    local keys = vim.api.nvim_replace_termcodes('gggqG', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
  end, { desc = 'Format GSQL file with textwidth and comments' })
end
