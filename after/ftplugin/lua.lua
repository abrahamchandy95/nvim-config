local set = vim.opt_local
set.shiftwidth = 2
set.number = true
set.relativenumber = true
if not (vim.bo.textwidth and vim.bo.textwidth > 0) then
  vim.bo.textwidth = 78
end
vim.wo.colorcolumn = tostring(vim.bo.textwidth + 1)

-- prevent your global LSP-on-save formatter for this buffer
-- (your global config checks/sets b:_my_lsp_fmt; set it now)
vim.b._my_lsp_fmt = true

-- also disable lua_ls formatting capability (belt + suspenders)
local grp = vim.api.nvim_create_augroup("lua.stylua", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = grp,
  buffer = 0,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "lua_ls" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
})

-- format with stylua on save (whole file)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grp,
  buffer = 0,
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
