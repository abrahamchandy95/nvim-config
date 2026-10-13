-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- don't jump to the last cursor position when reopening a file
vim.api.nvim_del_augroup_by_name("lazyvim_last_loc")

-- clicking the line numbers should only move the cursor, not toggle folds
-- (snacks wraps the whole statuscolumn, numbers included, in a click handler that runs `za`)
local function click_only_moves_cursor()
  require("snacks.statuscolumn").click_fold = function()
    local pos = vim.fn.getmousepos()
    vim.api.nvim_win_set_cursor(pos.winid, { pos.line, 0 })
  end
end

-- without a file argument LazyVim loads this file from inside its VeryLazy handler,
-- and a VeryLazy autocmd added at that point never fires: run it right away then
if vim.v.vim_did_enter == 1 then
  click_only_moves_cursor()
else
  vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", once = true, callback = click_only_moves_cursor })
end
