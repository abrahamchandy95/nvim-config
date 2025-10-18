local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smarttab = true
opt.encoding = "utf-8"
opt.visualbell = true
opt.scrolloff = 5
opt.fillchars = { eob = " " }
opt.background = "dark"
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.textwidth = 78
opt.colorcolumn = "+1"
-- Make Neovim actually insert line breaks while typing to respect 'textwidth'
-- If you only want comments to wrap, use "c" instead of "t".
opt.formatoptions:append("t")
if vim.fn.has("termguicolors") == 1 then
  opt.termguicolors = true
end
