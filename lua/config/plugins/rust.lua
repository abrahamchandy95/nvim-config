-- Rust support, via rustaceanvim (which owns starting rust-analyzer itself,
-- so rust-analyzer must NOT also be enabled in config/lsp/servers.lua).
--
-- Note on how rust-analyzer is located: rustaceanvim runs the first
-- `rust-analyzer` on PATH. Under rustup that is a proxy shim which re-resolves
-- per directory, so inside a project pinned by rust-toolchain.toml it runs
-- *that* toolchain's rust-analyzer rather than the default toolchain's. A
-- toolchain installed with `profile = "minimal"` ships no rust-analyzer
-- component, so the proxy exits immediately with
-- "Unknown binary 'rust-analyzer' in official toolchain ...".
--
-- That failure is otherwise invisible: rustaceanvim's auto_attach guard only
-- asks `executable("rust-analyzer")`, which is true for the proxy shim even
-- when the toolchain it resolves to has no binary behind it. The result is an
-- LSP that never attaches and never explains why. The preflight below actually
-- executes the resolved binary and reports the one-line fix.

local ROOT_MARKERS = { "rust-toolchain.toml", "rust-toolchain", "Cargo.toml" }

local checked_roots = {}
local warned_toolchains = {}

--- Probe the rust-analyzer that the rustup proxy resolves to for `root`, and if
--- the pinned toolchain has no such binary, say so once with the fix.
---
--- Runs async, so opening a Rust file never blocks on it, and once per project
--- root, so a workspace of many crates costs at most one probe per root.
---@param root string
local function preflight(root)
  if checked_roots[root] then
    return
  end
  checked_roots[root] = true

  -- The rustup proxy resolves against the working directory, hence cwd.
  vim.system({ "rust-analyzer", "--version" }, { cwd = root, text = true }, function(probe)
    if probe.code == 0 then
      return
    end

    -- Only the missing-component case is actionable here. Anything else (no
    -- rustup at all, no rust-analyzer on PATH) is left to rustaceanvim.
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
          .. "Fix:\n"
          .. ("  rustup component add rust-analyzer --toolchain %s\n\n"):format(toolchain)
          .. 'To fix it for every machine and for CI, add "rust-analyzer" to '
          .. "the components list in the project's rust-toolchain.toml.",
        vim.log.levels.WARN,
        { title = "rustaceanvim" }
      )
    end)
  end)
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- rustaceanvim is already lazy (ftplugin)
    init = function()
      -- Configure before the plugin loads (important)
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                buildScripts = { enable = true },
              },
              procMacro = { enable = true },

              -- Lints on save (clippy)
              checkOnSave = true,
              check = { command = "clippy" },
            },
          },
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RustAnalyzerPreflight", { clear = true }),
        pattern = "rust",
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if vim.bo[args.buf].buftype ~= "" or path == "" then
            return
          end
          local dir = vim.fn.fnamemodify(path, ":h")
          preflight(vim.fs.root(path, ROOT_MARKERS) or dir)
        end,
      })
    end,
  },
}
