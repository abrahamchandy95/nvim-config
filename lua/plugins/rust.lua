-- rust: LazyVim's rust extra owns rustaceanvim and rust-analyzer's settings.
--
-- `rust-analyzer` on PATH is usually rustup's proxy, which picks the toolchain
-- per directory: inside a project pinned by rust-toolchain.toml it runs that
-- toolchain's rust-analyzer. A toolchain installed with `profile = "minimal"`
-- has none, so the server exits at once ("Unknown binary 'rust-analyzer' in
-- official toolchain ...") and nothing in the editor says why. The extra only
-- checks that the proxy exists, so this runs the resolved binary once per
-- project and names the fix.

local ROOT_MARKERS = { "rust-toolchain.toml", "rust-toolchain", "Cargo.toml" }

local checked_roots = {}
local warned_toolchains = {}

-- Async and once per project root, so opening a Rust file never waits on it.
local function preflight(root)
  if checked_roots[root] then
    return
  end
  checked_roots[root] = true

  -- the proxy resolves the toolchain from its working directory
  vim.system({ "rust-analyzer", "--version" }, { cwd = root, text = true }, function(probe)
    if probe.code == 0 then
      return
    end
    -- only the missing-component case is ours; a missing proxy is reported by the extra
    local toolchain = (probe.stderr or ""):match("official toolchain '([^']+)'")
    if not toolchain or warned_toolchains[toolchain] then
      return
    end
    warned_toolchains[toolchain] = true
    vim.schedule(function()
      vim.notify(
        ("rust-analyzer is not installed for the toolchain this project pins (%s), so the LSP cannot start here.\n\n"):format(
          toolchain
        )
          .. ("Fix:\n  rustup component add rust-analyzer --toolchain %s\n\n"):format(toolchain)
          .. 'To fix it for every machine and for CI, add "rust-analyzer" to the components '
          .. "list in the project's rust-toolchain.toml.",
        vim.log.levels.WARN,
        { title = "rustaceanvim" }
      )
    end)
  end)
end

return {
  {
    "mrcjkb/rustaceanvim",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RustAnalyzerPreflight", { clear = true }),
        pattern = "rust",
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if vim.bo[args.buf].buftype ~= "" or path == "" then
            return
          end
          preflight(vim.fs.root(path, ROOT_MARKERS) or vim.fs.dirname(path))
        end,
      })
    end,
  },

  -- K and <leader>a use rustaceanvim's grouped hover and code actions. They used to live in
  -- after/ftplugin/rust.lua, but LazyVim maps K to plain hover when the client attaches, which is
  -- later. Keys under a server's name are applied after the "*" ones; `enabled = false` stops
  -- lspconfig from starting a second client, since rustaceanvim starts this one itself.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["rust-analyzer"] = {
          enabled = false,
          keys = {
            {
              "K",
              function()
                vim.cmd.RustLsp({ "hover", "actions" })
              end,
              desc = "Hover Actions (Rust)",
            },
            {
              "<leader>a",
              function()
                vim.cmd.RustLsp("codeAction")
              end,
              desc = "Code Action (Rust)",
            },
          },
        },
      },
    },
  },
}
