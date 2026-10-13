-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- find a word anywhere in the repo: the dashboard's "Find Text", from the git root
vim.keymap.set("n", "<leader>fw", function()
  LazyVim.pick.open("live_grep", { cwd = LazyVim.root.git() })
end, { desc = "Find Word in Repo (Git Root)" })