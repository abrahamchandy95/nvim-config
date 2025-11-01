return {
  {
    "neovim/nvim-lspconfig",
    -- ensure LSP is configured *before* FileType fires
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
      local util = require("lspconfig.util")

      -- capabilities (blink.cmp augments completion)
      local capabilities = require("blink.cmp").get_lsp_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      local function with_caps(opts)
        opts = opts or {}
        opts.capabilities =
          vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
        return opts
      end

      -- only enable servers whose binaries exist (quietly)
      local function has(bin)
        return vim.fn.exepath(bin) ~= ""
      end
      local function enable_if(bin, server)
        if has(bin) then
          vim.lsp.enable(server)
        end
      end

      ---------------------------------------------------------------------------
      -- Lua
      ---------------------------------------------------------------------------
      vim.lsp.config(
        "lua_ls",
        with_caps({
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        })
      )
      enable_if("lua-language-server", "lua_ls") -- mason: lua-language-server

      ---------------------------------------------------------------------------
      -- Python: type checking (basedpyright) + linting (ruff native server)
      ---------------------------------------------------------------------------
      vim.lsp.config(
        "basedpyright",
        with_caps({
          settings = {
            python = { analysis = { typeCheckingMode = "standard" } },
          },
        })
      )
      enable_if("basedpyright-langserver", "basedpyright")

      vim.lsp.config("ruff", with_caps({}))
      enable_if("ruff", "ruff") -- runs `ruff server` (native). ruff_lsp is deprecated.

      ---------------------------------------------------------------------------

      -- C / C++
      vim.lsp.config(
        "clangd",
        with_caps({
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },

          -- Prefer repo root (topmost .git). If absent, fall back to common build markers.
          root_markers = {
            ".clangd",
            "compile_commands.json",
            "compile_flags.txt",
            "Makefile",
            ".git",
          },
          root_dir = function(fname)
            local repo = vim.fs.root(fname, { ".git" })
            local build = vim.fs.root(
              fname,
              {
                ".clangd",
                "compile_commands.json",
                "compile_flags.txt",
                "Makefile",
              }
            )
            return repo
              or build
              or vim.fs.dirname(fname)
              or (vim.uv or vim.loop).cwd()
          end,

          single_file_support = true,
          cmd = { "clangd", "--background-index", "--clang-tidy" },

          -- Inject flags before clangd initializes (works with Neovim's new LSP flow).
          before_init = function(_params, cfg)
            local uv, fs = (vim.uv or vim.loop), vim.fs
            local repo = cfg.root_dir or uv.cwd()

            -- collect -I paths from:
            --   a) every Makefile's -I tokens,
            --   b) any dir named include/includes/inc/headers anywhere under repo.
            local seen, flags = {}, { "-xc", "-std=c17" }

            local function add_I(path)
              if not path or path == "" then
                return
              end
              if not path:match("^/") then
                path = repo .. "/" .. path
              end
              local st = uv.fs_stat(path)
              if st and st.type == "directory" and not seen[path] then
                seen[path] = true
                table.insert(flags, "-I" .. path)
              end
            end

            -- (a) scrape all Makefiles for -Ifoobar
            for _, mk in
              ipairs(
                fs.find(
                  "Makefile",
                  { path = repo, type = "file", limit = 8000 }
                )
              )
            do
              local f = io.open(mk, "r")
              if f then
                local s = f:read("*a") or ""
                f:close()
                for inc in s:gmatch("%-I%s*([^%s]+)") do
                  add_I(inc)
                end
              end
            end

            -- (b) add all include-like directories anywhere under the repo
            for _, name in ipairs({ "include", "includes", "inc", "headers" }) do
              for _, dir in
                ipairs(
                  fs.find(
                    name,
                    { path = repo, type = "directory", limit = 8000 }
                  )
                )
              do
                add_I(dir)
              end
            end

            cfg.init_options = cfg.init_options or {}
            cfg.init_options.fallbackFlags = flags
          end,
        })
      )
      enable_if("clangd", "clangd")

      ---------------------------------------------------------------------------
      -- TypeScript / JavaScript (vtsls for language features; ESLint formats)
      ---------------------------------------------------------------------------
      vim.lsp.config(
        "vtsls",
        with_caps({
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
          init_options = { hostInfo = "neovim" },
        })
      )
      enable_if("vtsls", "vtsls") -- provided by @vtsls/language-server (binary: vtsls) :contentReference[oaicite:2]{index=2}

      ---------------------------------------------------------------------------
      -- ESLint (diagnostics, code actions, formatting)
      ---------------------------------------------------------------------------
      vim.lsp.config(
        "eslint",
        with_caps({
          settings = {
            eslint = {
              workingDirectory = { mode = "auto" },
              format = { enable = true },
              codeAction = {
                disableRuleComment = { enable = true },
                showDocumentation = { enable = true },
              },
            },
          },
        })
      )
      enable_if("vscode-eslint-language-server", "eslint") -- mason: eslint-lsp

      ---------------------------------------------------------------------------
      -- Format-on-save: pick exactly one client per buffer
      ---------------------------------------------------------------------------
      local grp = vim.api.nvim_create_augroup("my.lsp", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          if
            client.supports_method
            and client:supports_method("textDocument/formatting")
          then
            if not vim.b[args.buf]._my_lsp_fmt then
              vim.b[args.buf]._my_lsp_fmt = true
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = grp,
                buffer = args.buf,
                callback = function()
                  vim.lsp.buf.format({
                    bufnr = args.buf,
                    id = client.id,
                    timeout_ms = 1000,
                  })
                end,
              })
            end
          end
        end,
      })

      ---------------------------------------------------------------------------
      -- Late-attach shim for clangd (covers already-open C buffers)
      ---------------------------------------------------------------------------
      local late_grp =
        vim.api.nvim_create_augroup("my.lsp.late", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = late_grp,
        pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
        callback = function(args)
          if
            #vim.lsp.get_clients({ bufnr = args.buf, name = "clangd" }) > 0
          then
            return
          end
          if not has("clangd") then
            return
          end
          local fname = vim.api.nvim_buf_get_name(args.buf)
          local root = util.root_pattern(
            "compile_commands.json",
            "compile_flags.txt",
            "Makefile",
            ".git"
          )(fname) or util.find_git_ancestor(fname) or (
            vim.uv or vim.loop
          ).cwd()
          vim.lsp.start({
            name = "clangd",
            cmd = { "clangd", "--background-index", "--clang-tidy" },
            root_dir = root,
            capabilities = capabilities,
          })
        end,
      })
    end,
  },
}
