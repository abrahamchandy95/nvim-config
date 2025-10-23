return {
  {
    "navarasu/onedark.nvim",
    lazy = false,    -- load during startup
    priority = 1000, -- load before other start plugins
    opts = {
      style = "dark",
    },
    config = function(_, opts)
      require("onedark").setup(opts)
      require("onedark").load() -- applies the colorscheme

      -- your tweaks (run AFTER the theme is loaded)
      vim.api.nvim_set_hl(0, "Normal", { bg = "#1E2127" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#1E2127" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "#1E2127" })
    end,
  },
}
