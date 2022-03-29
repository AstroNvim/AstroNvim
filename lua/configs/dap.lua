local M = {}

function M.ui_config()
  local status_ok, dapui = pcall(require, "dapui")
  if not status_ok then
    return
  end

  dapui.setup(require("core.utils").user_plugin_opts("plugins.dapui", {}))

  local dap = require "dap"
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

function M.install_config()
  local status_ok, dap_install = pcall(require, "dap-install")
  if not status_ok then
    return
  end

  dap_install.setup(require("core.utils").user_plugin_opts("plugins.dap_install", {}))
end

return M
