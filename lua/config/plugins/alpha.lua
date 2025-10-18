return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- === Colors (Arch blue & accents) ===
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#1793D1", bold = true })
    vim.api.nvim_set_hl(0, "AlphaButton", { fg = "#89B4FA" })
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#94E2D5" })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#7DC4E4", italic = true })
    -- === Big Arch header ===
    dashboard.section.header.val = {
      "                                                                 ",
      "                                -`                               ",
      "                               .o+`                              ",
      "                              `ooo/                              ",
      "                             `+oooo:                             ",
      "                            `+oooooo:                            ",
      "                            -+oooooo+:                           ",
      "                          `/:-:++oooo+:                          ",
      "                         `/++++/+++++++:                         ",
      "                        `/++++++++++++++:                        ",
      "                       `/+++ooooooooooooo/`                      ",
      "                      ./ooosssso++osssssso+`                     ",
      "                     .oossssso-````/ossssss+`                    ",
      "                    -osssssso.      :ssssssso.                   ",
      "                   :osssssss/        osssso+++.                  ",
      "                  /ossssssss/        +ssssooo/-                  ",
      "                `/ossssso+/:-        -:/+osssso+-                ",
      "               `+sso+:-`                 `.-/+oso:               ",
      "              `++:.                           `-/+/              ",
      "              .`                                 `/              ",
      "                                                                 ",
    }
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- === Buttons ===
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("SPC ee", "  > Open Oil (cwd)", "<cmd>Oil<CR>"),
      dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    -- color the button text and shortcuts
    for _, b in ipairs(dashboard.section.buttons.val) do
      b.opts.hl = "AlphaButton"
      b.opts.hl_shortcut = "AlphaShortcut"
    end

    -- === Footer (optional) ===
    dashboard.section.footer.val = "Arch Linux • happy hacking"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Layout + setup
    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)

    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
