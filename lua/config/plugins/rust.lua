return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- rustaceanvim is already lazy (ftplugin)
    init = function()
      -- Configure before the plugin loads (important)
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                buildScripts = { enable = true },
              },
              procMacro = { enable = true },

              -- Lints on save (clippy)
              checkOnSave = true,
              check = { command = "clippy" },
            },
          },
        },
      }
    end,
  },
}
