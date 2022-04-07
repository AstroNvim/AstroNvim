-- Global objects
globals = {
  "PACKER_BOOTSTRAP",
  "_LAZYGIT_TOGGLE",
  "_PYTHON_TOGGLE",
  "_NODE_TOGGLE",
  "_NCDU_TOGGLE",
  "_HTOP_TOGGLE",
  "vim",
  "C",
  "packer_plugins",
}

-- Rerun tests only if their modification time changed
cache = true

-- Don't report unused self arguments of methods
self = false

ignore = {
  "631",  -- max_line_length
  "212/_.*",  -- unused argument, for vars with "_" prefix
}
