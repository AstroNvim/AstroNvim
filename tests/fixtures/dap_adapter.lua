local sequence = 0
local event_log = os.getenv "ASTRONVIM_E2E_DAP_LOG"
local source_path = os.getenv "ASTRONVIM_E2E_DAP_SOURCE" or vim.fn.getcwd() .. "/plain.txt"

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

local function log_command(command)
  if not event_log then return end
  local file = assert(io.open(event_log, "ab"))
  file:write(vim.json.encode { command = command }, "\n")
  file:close()
end

local function send(message)
  sequence = sequence + 1
  message.seq = sequence
  local body = vim.json.encode(message)
  io.write("Content-Length: " .. #body .. "\r\n\r\n" .. body)
  io.flush()
end

local function respond(request, body)
  log_command(request.command)
  send {
    type = "response",
    request_seq = request.seq,
    command = request.command,
    success = true,
    body = body,
  }
end

local function send_event(event, body) send { type = "event", event = event, body = body } end

while true do
  local message = read_message()
  if not message then return end

  if message.type == "request" then
    if message.command == "initialize" then
      respond(message, {
        supportsConfigurationDoneRequest = true,
        supportsTerminateRequest = true,
      })
    elseif message.command == "launch" then
      respond(message)
      send_event "initialized"
    elseif message.command == "setBreakpoints" then
      respond(message, { breakpoints = {} })
    elseif message.command == "configurationDone" then
      respond(message)
      send_event("stopped", { reason = "entry", threadId = 1, allThreadsStopped = true })
    elseif message.command == "threads" then
      respond(message, { threads = { { id = 1, name = "AstroNvim fixture" } } })
    elseif message.command == "stackTrace" then
      respond(message, {
        stackFrames = {
          {
            id = 1,
            name = "AstroNvim fixture",
            line = 1,
            column = 1,
            source = { path = source_path, name = "plain.txt" },
          },
        },
        totalFrames = 1,
      })
    elseif message.command == "scopes" then
      respond(message, { scopes = {} })
    elseif message.command == "variables" then
      respond(message, { variables = {} })
    elseif message.command == "terminate" or message.command == "disconnect" then
      respond(message)
      send_event "terminated"
      return
    else
      log_command("unexpected:" .. message.command)
      send {
        type = "response",
        request_seq = message.seq,
        command = message.command,
        success = false,
        message = "Unsupported fixture request: " .. message.command,
      }
    end
  end
end
