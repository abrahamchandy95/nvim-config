local M = {}

function M.setup(capabilities)
  -- Lua
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })

  -- Python
  vim.lsp.config("basedpyright", {
    settings = {
      python = {
        analysis = { typeCheckingMode = "standard" },
      },
    },
  })
  vim.lsp.config("ruff", {})

  -- Go
  vim.lsp.config("gopls", {
    settings = {
      gopls = {
        usePlaceholders = true,
        completeUnimported = true,
        gofumpt = true,
        staticcheck = true,
      },
    },
  })

  -- TypeScript
  vim.lsp.config("vtsls", {
    settings = {
      typescript = {
        format = { enable = false },
        inlayHints = {
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
        },
      },
    },
  })

  -- Web / Configs
  vim.lsp.config("taplo", { cmd = { "taplo", "lsp", "stdio" } })
  vim.lsp.config("eslint", {
    settings = { eslint = { workingDirectory = { mode = "auto" } } },
  })

  -- Enable each server only if its executable is on PATH.
  -- Keys are lspconfig names; values are the actual binaries, which
  -- do not always match the server name (e.g. lua_ls).
  local servers = {
    lua_ls = "lua-language-server",
    basedpyright = "basedpyright-langserver",
    ruff = "ruff",
    gopls = "gopls",
    vtsls = "vtsls",
    taplo = "taplo",
    eslint = "vscode-eslint-language-server",
  }
  for name, bin in pairs(servers) do
    if vim.fn.exepath(bin) ~= "" then
      vim.lsp.enable(name)
    end
  end
end

return M
