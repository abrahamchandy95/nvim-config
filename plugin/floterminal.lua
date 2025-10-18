local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

local function create_floating_window(opts)
  opts             = opts or {}
  local width      = opts.width or math.floor(vim.o.columns * 0.8)
  local height     = opts.height or math.floor(vim.o.lines * 0.8)

  local col        = math.floor((vim.o.columns - width) / 2)
  local row        = math.floor((vim.o.lines - height) / 2)

  -- Reuse provided buf if valid; otherwise create a fresh scratch buf
  local buf        = (opts.buf and vim.api.nvim_buf_is_valid(opts.buf)) and opts.buf
      or vim.api.nvim_create_buf(false, true)

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }
  local win        = vim.api.nvim_open_win(buf, true, win_config)
  return { buf = buf, win = win }
end

vim.api.nvim_create_user_command("Floterminal", function()
  local win_ok = (state.floating.win ~= -1) and vim.api.nvim_win_is_valid(state.floating.win)

  if not win_ok then
    -- (Re)open the floating window, trying to reuse the terminal buffer if we have one
    state.floating = create_floating_window { buf = state.floating.buf }

    -- If we don't have a valid terminal buffer yet, or the buf isn't a terminal, start one
    local buf_valid = (state.floating.buf ~= -1) and vim.api.nvim_buf_is_valid(state.floating.buf)
    local is_term = buf_valid and (vim.bo[state.floating.buf].buftype == 'terminal')

    if not is_term then
      -- This will create a *new* terminal buffer in the current floating window
      vim.cmd.terminal()
      -- Capture and remember the terminal buffer so we can reuse it next time
      state.floating.buf = vim.api.nvim_get_current_buf()
    end

    -- Nice UX for terminal
    vim.cmd.startinsert()
  else
    -- Hide the floating window; keep the terminal buffer alive for reuse
    vim.api.nvim_win_hide(state.floating.win)
    state.floating.win = -1
  end
end, {})

-- Keymap: <leader>tt to toggle your floating terminal
vim.keymap.set('n', '<leader>tt', '<cmd>Floterminal<CR>', { desc = 'Toggle floating terminal' })
