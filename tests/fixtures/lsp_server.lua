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

while true do
  local message = read_message()
  if not message then return end

  if message.method == "initialize" then
    send_message {
      jsonrpc = "2.0",
      id = message.id,
      result = {
        capabilities = {
          textDocumentSync = 1,
          documentFormattingProvider = true,
          workspace = { fileOperations = { dynamicRegistration = true } },
        },
        serverInfo = { name = "AstroNvim e2e LSP", version = "1" },
      },
    }
  elseif message.method == "initialized" then
    send_message {
      jsonrpc = "2.0",
      id = 100,
      method = "client/registerCapability",
      params = {
        registrations = {
          {
            id = "astronvim-e2e-file-operations",
            method = "workspace/didCreateFiles",
            registerOptions = {},
          },
        },
      },
    }
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
