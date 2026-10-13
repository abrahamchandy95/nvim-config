return {
  -- diagnostics on the current line only, shown as virtual lines instead of end-of-line text
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        virtual_lines = { current_line = true },
      },
    },
  },

  -- no session restore
  { "folke/persistence.nvim", enabled = false },
}
