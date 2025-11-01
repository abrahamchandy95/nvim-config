vim.g.mapleader = " "

local keymap = vim.keymap

local function toggle_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      pcall(vim.api.nvim_win_close, win, true)
      return
    end
  end
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 5)
  vim.cmd.startinsert()
end

keymap.set(
  "n",
  "<leader>st",
  toggle_terminal,
  { desc = "Toggle terminal split" }
)
keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })
-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set(
  "n",
  "<leader>sh",
  "<C-w>s",
  { desc = "Split window horizontally" }
)
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set(
  "n",
  "<leader>sx",
  "<cmd>close<CR>",
  { desc = "Close current split" }
)

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set(
  "n",
  "<leader>tx",
  "<cmd>tabclose<CR>",
  { desc = "Close current tab" }
)
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to prev tab" })
keymap.set(
  "n",
  "<leader>tf",
  "<cmd>tabnew %<CR>",
  { desc = "Open current buffer in new tab" }
)
