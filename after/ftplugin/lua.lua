local set = vim.opt_local
set.shiftwidth = 2
set.number = true
set.relativenumber = true
if not (vim.bo.textwidth and vim.bo.textwidth > 0) then
  vim.bo.textwidth = 78
end
vim.wo.colorcolumn = tostring(vim.bo.textwidth + 1)

-- Stylua owns formatting for Lua buffers: this guard stops the global
-- LSP format-on-save autocmd (lua/config/plugins/lsp.lua) from
-- registering for this buffer.
vim.b.lsp_format_on_save = true

-- format with stylua on save (whole file)
local bufnr = vim.api.nvim_get_current_buf()
-- augroup is unique per buffer so re-sourcing this ftplugin for a new
-- buffer doesn't clear the autocmds of previously opened Lua buffers
local grp =
  vim.api.nvim_create_augroup("lua.stylua." .. bufnr, { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grp,
  buffer = bufnr,
  callback = function()
    if vim.fn.executable("stylua") ~= 1 then return end

    local column = (vim.bo.textwidth and vim.bo.textwidth > 0) and vim.bo.textwidth or 78
    local filepath = vim.api.nvim_buf_get_name(0)

    -- StyLua breaks long function calls across lines when they exceed --column-width.
    -- We pass --stdin-filepath so StyLua knows filetype and can honor any stylua.toml above.
    local cmd = table.concat({
      "silent keepjumps %!stylua",
      "--search-parent-directories",
      "--stdin-filepath", vim.fn.shellescape(filepath),
      "--indent-type", "Spaces",
      "--indent-width", "2",
      "--column-width", tostring(column),
      "-", -- read from stdin, write to stdout
    }, " ")

    vim.cmd(cmd)
  end,
})
