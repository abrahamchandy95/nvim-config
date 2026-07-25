return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      pip = {
        upgrade_pip = true,
      },
      registries = {
        "github:mason-org/mason-registry",
        -- community registry that packages the Roslyn .NET language server
        "github:Crashdummyy/mason-registry",
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "lua-language-server",
        "basedpyright",
        "ruff",
        "gopls",
        "vtsls",
        "taplo",
        "eslint-lsp",
        "stylua",
        "roslyn",
      },
    })
  end,
}
