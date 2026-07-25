return {
  {
    -- .NET / C# via Microsoft's Roslyn language server.
    -- The server binary is the Mason "roslyn" package (installed through
    -- the Crashdummyy registry configured in mason.lua) and needs the
    -- dotnet SDK on the machine to run.
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
    config = function(_, opts)
      require("roslyn").setup(opts)

      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
        },
      })
    end,
  },
}
