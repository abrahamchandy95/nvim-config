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
      local util = require("lspconfig.util")
      -- Capabilities for completion (blink.cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- helper to inject capabilities into server opts
      local function with_caps(opts)
        opts = opts or {}
        opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
        return opts
      end

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

      vim.lsp.config("clangd", with_caps({
        -- pick a sensible project root
        root_dir = util.root_pattern("compile_commands.json", "Makefile", ".git"),

        -- inject fallback flags per project root
        on_new_config = function(new_config, new_root_dir)
          new_config.init_options = new_config.init_options or {}
          new_config.init_options.fallbackFlags = {
            "-std=c11",
            "-I" .. new_root_dir .. "/include",
          }
        end,
      }))
      vim.lsp.enable("clangd")

      -- TypeScript & JS language features
      vim.lsp.config("vtsls", with_caps({
        -- Let ESLint own formatting for TS/JS
        settings = {
          typescript = {
            format = { enable = false },
            preferences = { importModuleSpecifier = "non-relative" },
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
            },
          },
          javascript = { format = { enable = false } },
        },
      }))
      vim.lsp.enable("vtsls")

      -- ESLint (diagnostics, code actions, and formatting)
      vim.lsp.config("eslint", with_caps({
        settings = {
          eslint = {
            workingDirectory = { mode = "auto" },
            format = { enable = true }, -- exposes textDocument/formatting
            codeAction = {
              disableRuleComment = { enable = true },
              showDocumentation = { enable = true },
            },
          },
        },
      }))
      vim.lsp.enable("eslint")

      -- ---------- On-attach formatting control ----------
      local grp = vim.api.nvim_create_augroup("my.lsp", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client.name == "clangd" then
            -- Belt & suspenders: disable formatting capability on this buffer
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            return
          end
          if client.supports_method and client:supports_method("textDocument/formatting") then
            if not vim.b[args.buf]._my_lsp_fmt then
              vim.b[args.buf]._my_lsp_fmt = true
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = grp,
                buffer = args.buf,
                callback = function()
                  -- Format only with this client (no surprises with multiple servers)
                  vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                end,
              })
            end
          end
        end,
      })
      -- --------------------------------------------------------
    end,
  },
}
