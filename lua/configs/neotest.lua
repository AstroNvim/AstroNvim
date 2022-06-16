local status_ok, neotest = pcall(require, "neotest")
if status_ok then
  neotest.setup(
  {
    adapters = {
      require("neotest-python")({
        dap = { justMyCode = false },
        runner = "unittest",
      }),
      require("neotest-plenary"),
      require("neotest-vim-test")({
        ignore_file_types = { "python", "vim", "lua" },
      }),
    } 
  }
  )
end
