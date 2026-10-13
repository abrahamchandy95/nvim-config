-- GSQL (TigerGraph): file type, tree-sitter highlighting and the gsql-lsp
-- language server, from the local checkout of gsql-lsp.
--
-- * The plugin directory is `editors/neovim` of the repository. It carries the
--   file type detection, the highlight/indent/fold queries and the LSP config.
-- * The tree-sitter parser is compiled from `tree-sitter-gsql/src/parser.c` into
--   `editors/neovim/parser/gsql.so` the first time Neovim starts (and again when
--   the grammar changes). It needs a C compiler (`cc`).
-- * The language server is the `gsql-lsp` binary, found on $PATH
--   (installed with `cargo install --path crates/gsql-lsp --root ~/.local`).
return {
  {
    dir = vim.fn.expand("~/Developer/gsql-lsp/editors/neovim"),
    name = "gsql.nvim",
    lazy = false,
    config = function()
      require("gsql").setup({
        -- cmd = { "/path/to/gsql-lsp" }, -- only if it is not on $PATH
      })
    end,
  },

  -- A tiger-ish icon for .gsql files in the file tree, buffer line, statusline
  -- and pickers. Nerd Fonts have no TigerGraph logo; this is the cat face from
  -- Material Design Icons in TigerGraph orange (MiniIconsOrange).
  {
    "nvim-mini/mini.icons",
    opts = {
      filetype = { gsql = { glyph = "󰄛", hl = "MiniIconsOrange" } },
      extension = {
        gsql = { glyph = "󰄛", hl = "MiniIconsOrange" },
        gsq = { glyph = "󰄛", hl = "MiniIconsOrange" },
      },
    },
  },
}
