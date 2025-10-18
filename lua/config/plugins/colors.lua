return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night"
  },
  config = function(_, opts)
    vim.opt.termguicolors = true
    pcall(function() require("tokyonight").setup(opts) end)
    vim.cmd("colorscheme tokyonight-night")
  end,
}
