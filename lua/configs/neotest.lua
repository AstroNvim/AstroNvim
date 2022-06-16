local status_ok, neotest = pcall(require, "neotest")
if status_ok then
  local neotest_opts = astronvim.user_plugin_opts("plugins.neotest", {
  { "*" },
  {
    adapters = {
    } 
  }
  })
  neotest.setup(neotest_opts[1], neotest_opts[2])
end
