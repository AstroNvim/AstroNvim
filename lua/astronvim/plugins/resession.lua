return {
  "stevearc/resession.nvim",
  lazy = true,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>S"] = vim.tbl_get(opts, "_map_sections", "S")
        maps.n["<Leader>Sl"] = { function() require("resession").load "Last Session" end, desc = "Load last session" }
        maps.n["<Leader>Ss"] = { function() require("resession").save() end, desc = "Save this session" }
        maps.n["<Leader>SS"] = {
          function() require("resession").save(vim.fn.getcwd(), { dir = "dirsession" }) end,
          desc = "Save this dirsession",
        }
        maps.n["<Leader>St"] = { function() require("resession").save_tab() end, desc = "Save this tab's session" }
        maps.n["<Leader>Sd"] = { function() require("resession").delete() end, desc = "Delete a session" }
        maps.n["<Leader>SD"] =
          { function() require("resession").delete(nil, { dir = "dirsession" }) end, desc = "Delete a dirsession" }
        maps.n["<Leader>Sf"] = { function() require("resession").load() end, desc = "Load a session" }
        maps.n["<Leader>SF"] =
          { function() require("resession").load(nil, { dir = "dirsession" }) end, desc = "Load a dirsession" }
        maps.n["<Leader>S."] = {
          function() require("resession").load(vim.fn.getcwd(), { dir = "dirsession" }) end,
          desc = "Load current dirsession",
        }
        opts.autocmds.resession_auto_save = {
          {
            event = "VimLeavePre",
            desc = "Save session on close",
            callback = function()
              local buf_utils = require "astrocore.buffer"
              local autosave = buf_utils.sessions.autosave
              if autosave and buf_utils.is_valid_session() then
                local save = require("resession").save
                if autosave.last then save("Last Session", { notify = false }) end
                if autosave.cwd then save(vim.fn.getcwd(), { dir = "dirsession", notify = false }) end
              end
            end,
          },
        }
      end,
    },
  },
  opts = {
    buf_filter = function(bufnr) return require("astrocore.buffer").is_restorable(bufnr) end,
    tab_buf_filter = function(tabpage, bufnr) return vim.tbl_contains(vim.t[tabpage].bufs, bufnr) end,
    extensions = { astrocore = { enable_in_tab = true } },
  },
}
