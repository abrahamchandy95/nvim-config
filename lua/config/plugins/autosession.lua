return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    suppressed_dirs = { "~/", "~/Downloads", "/" },
    -- Always start on a clean slate: sessions are still saved on exit, but
    -- restoring one is an explicit choice (`SessionRestore`, or SPC wr on Alpha)
    auto_restore = false,
    auto_restore_last_session = false,
  },
}
