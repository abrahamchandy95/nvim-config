local logo = [[
                   -`
                  .o+`
                 `ooo/
                `+oooo:
               `+oooooo:
               -+oooooo+:
             `/:-:++oooo+:
            `/++++/+++++++:
           `/++++++++++++++:
          `/+++ooooooooooooo/`
         ./ooosssso++osssssso+`
        .oossssso-````/ossssss+`
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/        +ssssooo/-
   `/ossssso+/:-        -:/+osssso+-
  `+sso+:-`                 `.-/+oso:
 `++:.                           `-/+/
 .`                                 `/]]

local base = vim.split(logo, "\n")
-- pad to equal width so per-line centering keeps the logo's shape
local base_w = 0
for _, l in ipairs(base) do
  base_w = math.max(base_w, #l)
end
for i, l in ipairs(base) do
  base[i] = l .. string.rep(" ", base_w - #l)
end

-- rows used by everything except the logo (keys, recent files, startup, padding, editor chrome)
local RESERVED_ROWS = 22
local MAX_SCALE = 3

-- resample the logo (nearest neighbour) so it fits the current window
local function fit_logo()
  local avail_h = vim.o.lines - RESERVED_ROWS
  local avail_w = vim.o.columns - 4
  local s = math.min(avail_h / #base, avail_w / base_w, MAX_SCALE)
  s = math.max(s, 0.5)
  local rows, cols = math.max(1, math.floor(#base * s)), math.max(1, math.floor(base_w * s))
  local out = {}
  for r = 1, rows do
    local src = base[math.min(#base, math.floor((r - 1) / s) + 1)]
    local line = {}
    for c = 1, cols do
      local i = math.min(base_w, math.floor((c - 1) / s) + 1)
      line[c] = src:sub(i, i)
    end
    out[r] = table.concat(line)
  end
  return out, s
end

-- noir: warm amber light fading into cool shadow, interpolated per row
local from, to = { 0xff, 0xd9, 0x9c }, { 0x3a, 0x3a, 0x48 }
-- venetian blind: every third source line is slatted into shadow
local BLIND_EVERY, BLIND_DIM = 3, 0.3

local function row_color(r, rows, scale)
  local t = rows > 1 and (r - 1) / (rows - 1) or 0
  local k = (math.ceil(r / scale) % BLIND_EVERY == 0) and BLIND_DIM or 1
  local c = {}
  for n = 1, 3 do
    c[n] = math.floor((from[n] + (to[n] - from[n]) * t) * k + 0.5)
  end
  return string.format("#%02x%02x%02x", c[1], c[2], c[3])
end

local function set_accents()
  -- the single red accent, film-noir style
  vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#e0314b", bold = true })
  vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#8a8a94" })
end
set_accents()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_accents })

local function header()
  local rows, scale = fit_logo()
  local out = {}
  for r, l in ipairs(rows) do
    local group = "DashGrad" .. r
    vim.api.nvim_set_hl(0, group, { fg = row_color(r, #rows, scale), bold = true })
    out[#out + 1] = { text = { { l, hl = group } }, align = "center" }
  end
  out[#out].padding = 1
  return out
end

local keys = {
  { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
  { icon = " ", key = "n", desc = "New File", action = ":ene" },
  { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
  { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
  { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
  { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
  { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
  { icon = " ", key = "q", desc = "Quit", action = ":qa" },
}

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = { keys = keys },
      sections = {
        header,
        { section = "keys", gap = 0, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 3 },
        { section = "startup" },
      },
    },
  },
}
