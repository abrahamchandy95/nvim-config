return {
  -- python: basedpyright is the only language server (the extra also enables ruff)
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.ruff.enabled = false
    end,
  },

  -- c/c++: clangd finds build/compile_commands.json on its own, no copy to the root needed.
  -- Use a project's .clang-format when present, otherwise fall back to Google style.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      formatters = {
        ["clang-format"] = {
          prepend_args = { "--style=file", "--fallback-style=Google" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "clang-format" } },
  },
}
