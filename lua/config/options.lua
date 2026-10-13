-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.winborder = "rounded"
vim.opt.fillchars:append({ eob = " ", diff = "╱" })
vim.o.scrolloff = 8

-- python: basedpyright only (see lua/plugins/lang.lua for dropping ruff)
vim.g.lazyvim_python_lsp = "basedpyright"
