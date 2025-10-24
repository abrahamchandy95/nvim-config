-- lua/plugins/devicons-gsql.lua
return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 1000, -- ensure overrides are applied before others cache icons
  config = function()
    local devicons = require("nvim-web-devicons")
    devicons.setup({ default = true }) -- safe default
    devicons.set_icon({
      gsql = { icon = "", color = "#ec6408", cterm_color = "208", name = "GSQL" },
    })
  end,
}
