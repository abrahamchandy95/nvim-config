return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      -- keep Oil’s default keymaps (includes `-` parent and `g.` toggle hidden)
      use_default_keymaps = true,

      -- show dotfiles & don't permanently hide anything
      view_options = {
        show_hidden = true,     -- show files starting with "."
        natural_order = "fast", -- human-friendly sorting, fast mode
        is_hidden_file = function(name, _)
          -- mark dotfiles as "hidden" (they still show because show_hidden=true)
          return name:sub(1, 1) == "."
        end,
        is_always_hidden = function(_name, _)
          -- never force-hide anything (set to `name == ".git"` if you want to hide just the .git dir)
          return false
        end,
      },
    },

    -- Put your keymaps here so they’re tied to this plugin
    keys = {
      -- Open Oil in the current directory
      { "<leader>ee", "<CMD>Oil<CR>", desc = "Open Oil (file explorer)" },
    },

    dependencies = {
      {
        "nvim-mini/mini.icons",
        -- Give mini.icons the .gsql override
        config = function(_, opts)
          require("mini.icons").setup(vim.tbl_deep_extend("force", opts or {}, {
            extension = {
              gsql = { glyph = "", hl = "MiniIconsOrange" }, -- FA sitemap, TigerGraph orange
            },
          }))
          -- Optional: make devicons-based plugins use mini.icons everywhere
          -- MiniIcons.mock_nvim_web_devicons()
        end,
      },
    },

    -- Oil’s README recommends not lazy-loading to avoid edge cases
    lazy = false,
  },
}
