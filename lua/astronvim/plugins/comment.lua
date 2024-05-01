return {
  "numToStr/Comment.nvim",
  dependencies = {
    { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>/"] = {
          function() require("Comment.api").toggle.linewise.count(vim.v.count1) end,
          desc = "Toggle comment line",
        }
        maps.x["<Leader>/"] = {
          "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
          desc = "Toggle comment for selection",
        }
      end,
    },
  },
  keys = function(_, keys)
    local plugin = require("lazy.core.config").spec.plugins["Comment.nvim"]
    local opts = require("lazy.core.plugin").values(plugin, "opts", false)
    if vim.tbl_get(opts, "mappings", "basic") ~= false then
      vim.list_extend(keys, {
        { vim.tbl_get(opts, "toggler", "line") or "gcc", desc = "Comment toggle current line" },
        { vim.tbl_get(opts, "toggler", "block") or "gbc", desc = "Comment toggle current block" },
        { vim.tbl_get(opts, "opleader", "line") or "gc", desc = "Comment toggle linewise" },
        { vim.tbl_get(opts, "opleader", "block") or "gb", desc = "Comment toggle blockwise" },
        { vim.tbl_get(opts, "opleader", "line") or "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
        { vim.tbl_get(opts, "opleader", "block") or "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
      })
    end
    if vim.tbl_get(opts, "mappings", "extra") ~= false then
      vim.list_extend(keys, {
        { vim.tbl_get(keys, "extra", "below") or "gco", desc = "Comment insert below" },
        { vim.tbl_get(opts, "extra", "above") or "gcO", desc = "Comment insert above" },
        { vim.tbl_get(opts, "extra", "eol") or "gcA", desc = "Comment insert end of line" },
      })
    end
  end,
  opts = function(_, opts)
    local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
    if commentstring_avail then opts.pre_hook = commentstring.create_pre_hook() end
  end,
}
