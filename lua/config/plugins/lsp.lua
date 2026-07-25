return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "saghen/blink.cmp" },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
        },
      },
    },
    config = function()
      -- 1) Common Capabilities (used by all servers)
      local capabilities = require("blink.cmp").get_lsp_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      -- 2) Setup Global Defaults
      vim.lsp.config("*", { capabilities = capabilities })

      -- 3) Diagnostics UI (virtual text is off by default on 0.11+)
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- 4) Load Server Configurations
      require("config.lsp.clangd").setup(capabilities)
      require("config.lsp.servers").setup(capabilities)

      -- 5) Global Auto-Format on Save
      local grp =
        vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local bufnr = args.buf

          -- Ensure we only register ONE BufWritePre per buffer
          if vim.b[bufnr].lsp_format_on_save then
            return
          end
          vim.b[bufnr].lsp_format_on_save = true

          vim.api.nvim_create_autocmd("BufWritePre", {
            group = grp,
            buffer = bufnr,
            callback = function()
              local ft = vim.bo[bufnr].filetype

              -- For C-family, ALWAYS format with clangd (prevents fighting formatters)
              local want_clangd = (
                ft == "c"
                or ft == "cpp"
                or ft == "objc"
                or ft == "objcpp"
              )

              vim.lsp.buf.format({
                bufnr = bufnr,
                async = false,
                filter = function(client)
                  if want_clangd then
                    return client.name == "clangd"
                  end
                  return client:supports_method("textDocument/formatting")
                end,
              })
            end,
          })
        end,
      })
    end,
  },
}
