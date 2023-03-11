-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    -- NeoTest
      ["<leader>T"] = { "Tests" },
      ["<leader>Tn"] = {
        function() require("neotest").run.run() end,
        desc = "Run nearest test",
      },
      ["<leader>Tf"] = {
        function() require("neotest").run.run(vim.fn.expand "%") end,
        desc = "Run tests in current file",
      },
      ["<leader>To"] = {
        function() require("neotest").output.open() end,
        desc = "Display output of tests",
      },
      ["<leader>Ts"] = {
        function() require("neotest").summary.toggle() end,
        desc = "Open the summary window",
      },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
