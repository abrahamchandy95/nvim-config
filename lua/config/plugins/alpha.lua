return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- === Colors ===
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#1793D1", bold = true })
    vim.api.nvim_set_hl(0, "AlphaButton", { fg = "#89B4FA" })
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#94E2D5" })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#7DC4E4", italic = true })

    -- === Arch header (full) ===
    local header_full = {
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
    }

    -- A tiny emergency header if the window is *really* short
    local header_tiny = {
      "  _         ",
      " /_\\  Arch  ",
      "/ _ \\ Linux ",
      "\\___/       ",
    }

    -- Two button sets
    local buttons_full = {
      { "e", "  > New File", "<cmd>ene<CR>" },
      { "SPC ee", "  > Open Oil (cwd)", "<cmd>Oil<CR>" },
      { "SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>" },
      { "SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>" },
      { "SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>" },
      { "q", "  > Quit NVIM", "<cmd>qa<CR>" },
    }
    local buttons_compact = {
      { "e", "  New", "<cmd>ene<CR>" },
      { "SPC ee", "  Oil", "<cmd>Oil<CR>" },
      { "SPC ff", "󰱼  Files", "<cmd>Telescope find_files<CR>" },
      { "SPC fs", "  Grep", "<cmd>Telescope live_grep<CR>" },
      { "SPC wr", "󰁯  Session", "<cmd>SessionRestore<CR>" },
      { "q", "  Quit", "<cmd>qa<CR>" },
    }

    -- Helper: build dashboard buttons from tuples
    local function build_buttons(defs)
      local out = {}
      for _, b in ipairs(defs) do
        local btn = dashboard.button(b[1], b[2], b[3])
        btn.opts.hl = "AlphaButton"
        btn.opts.hl_shortcut = "AlphaShortcut"
        table.insert(out, btn)
      end
      return out
    end

    -- Helper: thin a list of lines to a target count by dropping evenly
    local function thin_lines(lines, target)
      local n = #lines
      if n <= target then return vim.deepcopy(lines) end
      local keep = {}
      -- Distribute kept rows across the original height
      for i = 1, target do
        local src = math.floor((i - 1) * (n - 1) / (target - 1) + 1)
        table.insert(keep, lines[src])
      end
      return keep
    end

    -- Fit everything to current window height
    local function fit_layout()
      local lines = vim.o.lines -- total screen rows
      local reserve = 0         -- rows we can't use (we hide UI, so 0)
      local avail = math.max(1, lines - reserve)

      -- start with roomy padding & full buttons
      local top_pad, mid_pad, bot_pad = 2, 1, 1
      local btn_defs = buttons_full
      local hdr = vim.deepcopy(header_full)
      local footer = "Arch Linux • happy hacking"

      local function total_height(hdr_lines, btn_count, tp, mp, bp, has_footer)
        local h = #hdr_lines + btn_count + (has_footer and 1 or 0)
        h = h + tp + mp + bp
        return h
      end

      -- Step 1: zero padding if needed
      while total_height(hdr, #btn_defs, top_pad, mid_pad, bot_pad, true) > avail
        and (top_pad + mid_pad + bot_pad) > 0 do
        if top_pad > 0 then
          top_pad = top_pad - 1
        elseif mid_pad > 0 then
          mid_pad = mid_pad - 1
        elseif bot_pad > 0 then
          bot_pad = bot_pad - 1
        end
      end

      -- Step 2: switch to compact buttons if still overflowing
      if total_height(hdr, #btn_defs, top_pad, mid_pad, bot_pad, true) > avail then
        btn_defs = buttons_compact
      end

      -- Step 3: thin the header to fit the remaining space (down to 4 lines)
      local must_fit = avail - (#btn_defs) - (footer and 1 or 0) - (top_pad + mid_pad + bot_pad)
      if must_fit < 4 then must_fit = 4 end
      if #hdr > must_fit then
        hdr = thin_lines(hdr, math.max(4, must_fit))
      end

      -- Step 4: if *still* too tall (ultra short terminals), use tiny header and minimal UI
      if total_height(hdr, #btn_defs, top_pad, mid_pad, bot_pad, true) > avail then
        hdr = header_tiny
        btn_defs = buttons_compact
        top_pad, mid_pad, bot_pad = 0, 0, 0
        if total_height(hdr, #btn_defs, top_pad, mid_pad, bot_pad, true) > avail then
          -- drop footer as last resort
          footer = nil
        end
      end

      -- Apply to dashboard
      dashboard.section.header.val = hdr
      dashboard.section.header.opts.hl = "AlphaHeader"

      dashboard.section.buttons.val = build_buttons(btn_defs)

      dashboard.section.footer.val = footer or ""
      dashboard.section.footer.opts.hl = "AlphaFooter"

      dashboard.config.layout = {
        { type = "padding", val = top_pad },
        dashboard.section.header,
        { type = "padding", val = mid_pad },
        dashboard.section.buttons,
        { type = "padding", val = bot_pad },
      }
      if footer then table.insert(dashboard.config.layout, dashboard.section.footer) end
    end

    -- Initial setup
    fit_layout()
    dashboard.opts.opts.noautocmd = true
    require("alpha").setup(dashboard.opts)

    -- === Alpha-only view tweaks to maximize space and avoid “middle start” ===
    local aug = vim.api.nvim_create_augroup("AlphaFit", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = aug,
      pattern = "alpha",
      callback = function()
        -- save globals to restore later
        vim.w._alpha_prev_laststatus  = vim.o.laststatus
        vim.w._alpha_prev_showtabline = vim.o.showtabline
        vim.w._alpha_prev_cmdheight   = vim.o.cmdheight

        -- reclaim rows
        vim.opt.laststatus            = 0
        vim.opt.showtabline           = 0
        pcall(function() vim.opt.cmdheight = 0 end) -- works on NVIM 0.9+

        -- no centering
        vim.opt_local.scrolloff = 0
        vim.opt_local.sidescrolloff = 0

        -- ensure we see the top
        vim.schedule(function()
          pcall(vim.cmd, "normal! gg0")
        end)
      end,
    })

    -- Restore globals when leaving Alpha
    vim.api.nvim_create_autocmd("BufUnload", {
      group = aug,
      pattern = "*",
      callback = function(args)
        if vim.bo[args.buf].filetype == "alpha" then
          if vim.w._alpha_prev_laststatus ~= nil then vim.opt.laststatus = vim.w._alpha_prev_laststatus end
          if vim.w._alpha_prev_showtabline ~= nil then vim.opt.showtabline = vim.w._alpha_prev_showtabline end
          if vim.w._alpha_prev_cmdheight ~= nil then pcall(function() vim.opt.cmdheight = vim.w._alpha_prev_cmdheight end) end
        end
      end,
    })

    -- Re-fit on resize while on Alpha
    vim.api.nvim_create_autocmd("VimResized", {
      group = aug,
      callback = function()
        if vim.bo.filetype == "alpha" then
          fit_layout()
          -- re-setup to apply new layout
          require("alpha").setup(dashboard.opts)
          vim.schedule(function()
            pcall(vim.cmd, "normal! gg0")
          end)
        end
      end,
    })

    -- Keep folds off
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
