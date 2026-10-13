-- The PostgreSQL clone is a read-only reference: no edits, so no format on save.
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = vim.fn.expand("~") .. "/opensource/postgresql/*",
  callback = function(args)
    vim.bo[args.buf].modifiable = false
    vim.bo[args.buf].readonly = true
  end,
})
