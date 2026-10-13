return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "thin",
        indicator = { style = "underline" },
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.globalstatus = true
      opts.options.component_separators = { left = "", right = "" }
      opts.options.section_separators = { left = "", right = "" }
    end,
  },
  {
    "folke/noice.nvim",
    opts = {
      presets = { lsp_doc_border = true },
      views = {
        cmdline_popup = { border = { style = "rounded", padding = { 0, 1 } } },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        chunk = { enabled = true },
        animate = {
          enabled = true,
          style = "out",
          duration = { step = 15, total = 300 },
        },
      },
      notifier = { style = "fancy" },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        keymap = { preset = "default" },
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
      },
    },
  },
}
