return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      -- (optional) keep the default keymaps, which already include `g.` to toggle hidden
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

      -- (optional) if you ever disable default keymaps, keep this so you can toggle quickly
      -- keymaps = { ["g."] = "actions.toggle_hidden" },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
  },
}
