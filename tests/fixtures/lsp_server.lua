local function read_message()
  local content_length
  while true do
    local line = io.read "*l"
    if not line then return nil end
    line = line:gsub("\r$", "")
    if line == "" then break end
    local name, value = line:match "^([^:]+):%s*(.*)$"
    if name == "Content-Length" then content_length = tonumber(value) end
  end
  if not content_length then return nil end
  local body = io.read(content_length)
  if not body then return nil end
  return vim.json.decode(body)
end

local function send_message(message)
  local body = vim.json.encode(message)
  io.write("Content-Length: " .. #body .. "\r\n\r\n" .. body)
  io.flush()
end

local operation_log = os.getenv "ASTRONVIM_E2E_LSP_LOG"
local function write_log(entry)
  if not operation_log then return end
  local file = assert(io.open(operation_log, "ab"))
  file:write(vim.json.encode(entry), "\n")
  file:close()
end

local function record_initialize(message)
  write_log {
    method = message.method,
    file_operations = vim.tbl_get(message, "params", "capabilities", "workspace", "fileOperations"),
  }
end

local function record_operation(message)
  local files = (message.params or {}).files or {}
  local first_file = files[1] or {}
  write_log { method = message.method, uri = first_file.uri }
end

local file_operation_options = {
  filters = {
    { scheme = "file", pattern = { glob = "**/*" } },
  },
}

local function register_file_operations()
  send_message {
    jsonrpc = "2.0",
    id = 100,
    method = "client/registerCapability",
    params = {
      registrations = {
        { id = "astronvim-e2e-file-create", method = "workspace/didCreateFiles", registerOptions = {} },
        { id = "astronvim-e2e-file-delete", method = "workspace/didDeleteFiles", registerOptions = {} },
        { id = "astronvim-e2e-file-rename", method = "workspace/didRenameFiles", registerOptions = {} },
        { id = "astronvim-e2e-file-will-create", method = "workspace/willCreateFiles", registerOptions = {} },
        { id = "astronvim-e2e-file-will-delete", method = "workspace/willDeleteFiles", registerOptions = {} },
        { id = "astronvim-e2e-file-will-rename", method = "workspace/willRenameFiles", registerOptions = {} },
      },
    },
  }
end

while true do
  local message = read_message()
  if not message then return end

  if message.method == "initialize" then
    record_initialize(message)
    send_message {
      jsonrpc = "2.0",
      id = message.id,
      result = {
        capabilities = {
          textDocumentSync = 1,
          documentFormattingProvider = true,
          workspace = {
            fileOperations = {
              dynamicRegistration = true,
              didCreate = file_operation_options,
              didDelete = file_operation_options,
              didRename = file_operation_options,
              willCreate = file_operation_options,
              willDelete = file_operation_options,
              willRename = file_operation_options,
            },
          },
        },
        serverInfo = { name = "AstroNvim e2e LSP", version = "1" },
      },
    }
  elseif message.method == "initialized" then
    register_file_operations()
  elseif
    message.method == "workspace/willCreateFiles"
    or message.method == "workspace/willDeleteFiles"
    or message.method == "workspace/willRenameFiles"
  then
    record_operation(message)
    send_message { jsonrpc = "2.0", id = message.id, result = vim.NIL }
  elseif
    message.method == "workspace/didCreateFiles"
    or message.method == "workspace/didDeleteFiles"
    or message.method == "workspace/didRenameFiles"
  then
    record_operation(message)
  elseif message.method == "textDocument/formatting" then
    send_message {
      jsonrpc = "2.0",
      id = message.id,
      result = {
        {
          range = {
            start = { line = 0, character = 0 },
            ["end"] = { line = 0, character = 0 },
          },
          newText = "-- formatted by e2e server\n",
        },
      },
    }
  elseif message.method == "shutdown" then
    send_message { jsonrpc = "2.0", id = message.id, result = vim.NIL }
  elseif message.method == "exit" then
    return
  elseif message.id and message.method == nil then
    -- Ignore responses to server requests.
  end
end
