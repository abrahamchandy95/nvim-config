return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      --    (built-in in noice)
      presets = {
        long_message_to_split = true, -- long messages → split
      },

      --    (this overrides the built-in "split" view)
      views = {
        split = { enter = true },
      },

      --    to open in a split (covers very verbose outputs)
      routes = {
        {
          view = "split",
          filter = { event = "msg_show", min_height = 15 },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- optional but recommended for notifications
    },
  },
}
