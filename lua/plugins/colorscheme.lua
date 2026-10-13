return {
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-mocha" } },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      float = { transparent = false, solid = false },
      term_colors = true,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
      },
      integrations = {
        snacks = { enabled = true, indent_scope_color = "lavender" },
        noice = true,
        blink_cmp = { style = "bordered" },
        which_key = true,
        flash = true,
        gitsigns = true,
        mason = true,
        treesitter_context = true,
        mini = { enabled = true },
      },
    },
  },
}
