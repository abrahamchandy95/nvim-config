return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- completion engine
      { "saghen/blink.cmp" },

      -- Lua dev experience (you already had this)
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },

    config = function()
      -- 1) Build shared capabilities (blink.cmp augments completion)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- helper to inject capabilities into server opts
      local function with_caps(opts)
        opts = opts or {}
        opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
        return opts
      end

      -- 2) LSP servers
      -- Lua
      vim.lsp.config("lua_ls", with_caps({
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }))
      vim.lsp.enable("lua_ls")

      -- Python
      vim.lsp.config("basedpyright", with_caps({
        settings = { python = { analysis = { typeCheckingMode = "standard" } } },
      }))
      vim.lsp.enable("basedpyright")

      vim.lsp.config("ruff_lsp", with_caps({}))
      vim.lsp.enable("ruff_lsp")

      -- C/C++
      vim.lsp.config("clangd", with_caps({}))
      vim.lsp.enable("clangd")

      -- 3) Format on save (unchanged)
      local grp = vim.api.nvim_create_augroup("my.lsp", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = grp,
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
              end,
            })
          end
        end,
      })
      -- --------------------------------------------------------
    end,
  },
}
