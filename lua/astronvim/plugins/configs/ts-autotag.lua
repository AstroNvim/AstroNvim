return function(_, opts)
  require("nvim-ts-autotag").setup(opts)
  require("astrocore").exec_buffer_autocmds("FileType", { group = "nvim_ts_xmltag" })
end
