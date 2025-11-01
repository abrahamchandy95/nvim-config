return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      ---@diagnostic disable: missing-fields
      configs.setup({
        -- hush LuaLS “missing fields” noise
        modules = {},
        ignore_install = {},

        ensure_installed = {
          "c", "cpp", "lua", "vim", "vimdoc", "query",
          "markdown", "markdown_inline", "typescript", "tsx",
        },
        sync_install = false,
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          -- disable TS highlighting for very large files
          disable = function(_, buf)
            local max = 100 * 1024 -- 100KB
            local uv = vim.uv or vim.loop
            local ok_stat, stat = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok_stat and stat and stat.size > max then
              return true
            end
            return false
          end,
        },
      })
    end,
  },
}
