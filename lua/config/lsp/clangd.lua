-- config/lsp/clangd.lua
local M = {}

function M.setup(capabilities)
  local uv = vim.uv or vim.loop
  local fs = vim.fs

  -- clangd wants UTF-16 offsets; keep this off the shared capabilities
  capabilities = vim.deepcopy(capabilities or {})
  ---@diagnostic disable-next-line: inject-field
  capabilities.offsetEncoding = { "utf-16" }

  local function norm(p)
    if not p or p == "" then
      return p
    end
    p = vim.fn.expand(p)
    p = vim.fn.fnamemodify(p, ":p")
    return fs.normalize(p)
  end

  local function exists(p)
    return uv.fs_stat(norm(p)) ~= nil
  end

  local function resolve_root(bufnr)
    bufnr = bufnr or 0
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if not fname or fname == "" then
      return norm(uv.cwd())
    end
    fname = norm(fname)

    local root = fs.root(fname, {
      ".git",
      ".clangd",
      "compile_commands.json",
      "CMakeLists.txt",
      "Makefile",
      "meson.build",
    })

    return norm(root or fs.dirname(fname) or uv.cwd())
  end

  local function clangd_bin()
    local p = vim.fn.exepath("clangd")
    if p and p ~= "" then
      return p
    end
    return "clangd"
  end

  local root0 = resolve_root(0)

  local cmd = {
    clangd_bin(),
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--offset-encoding=utf-16",
  }

  -- If build/compile_commands.json exists, point clangd at it.
  -- Otherwise clangd will still try its normal discovery.
  local cdb = root0 .. "/build/compile_commands.json"
  if exists(cdb) then
    table.insert(cmd, ("--compile-commands-dir=%s"):format(root0 .. "/build"))
  end

  vim.lsp.config("clangd", {
    name = "clangd",
    capabilities = capabilities,
    cmd = cmd,
    root_dir = function(bufnr, on_dir)
      on_dir(resolve_root(bufnr))
    end,
  })

  vim.lsp.enable("clangd")
end

return M
