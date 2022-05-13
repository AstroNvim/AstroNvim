local ui = {}

function ui.nui_input()
  -- Set up NUI for UI Input
  -- From: https://github.com/MunifTanjim/nui.nvim/wiki/vim.ui#vimuiinput
  local input_ui
  vim.ui.input = function(opts, on_confirm)
    local Input = require "nui.input"
    local event = require("nui.utils.autocmd").event
    if input_ui then
      -- ensure single ui.input operation
      vim.api.nvim_err_writeln "busy: another input is pending!"
      return
    end

    local function on_done(value)
      if input_ui then
        -- if it's still mounted, unmount it
        input_ui:unmount()
      end
      -- pass the input value
      on_confirm(value)
      -- indicate the operation is done
      input_ui = nil
    end

    local border_top_text = opts.prompt or "[Input]"
    local default_value = opts.default

    input_ui = Input({
      relative = "cursor",
      position = {
        row = 1,
        col = 0,
      },
      size = {
        -- minimum width 20
        width = math.max(20, type(default_value) == "string" and #default_value or 0),
      },
      border = {
        style = "rounded",
        highlight = "Normal",
        text = {
          top = border_top_text,
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal",
      },
    }, {
      default_value = default_value,
      on_close = function()
        on_done(nil)
      end,
      on_submit = function(value)
        on_done(value)
      end,
    })

    input_ui:mount()

    -- cancel operation if cursor leaves input
    input_ui:on(event.BufLeave, function()
      on_done(nil)
    end, { once = true })

    -- cancel operation if <Esc> is pressed
    input_ui:map("n", "<Esc>", function()
      on_done(nil)
    end, { noremap = true, nowait = true })
  end
end

function ui.telescope_select()
  -- Telescope UI selection
  -- From: https://github.com/stevearc/dressing.nvim/blob/master/lua/dressing/select/telescope.lua
  vim.ui.select = vim.schedule_wrap(function(items, opts, on_choice)
    local themes = require "telescope.themes"
    local actions = require "telescope.actions"
    local state = require "telescope.actions.state"
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values

    if opts.format_item then
      local format_item = opts.format_item
      opts.format_item = function(item)
        return tostring(format_item(item))
      end
    else
      opts.format_item = tostring
    end

    local entry_maker = function(item)
      local formatted = opts.format_item(item)
      return {
        display = formatted,
        ordinal = formatted,
        value = item,
      }
    end

    local picker_opts = themes.get_dropdown()

    pickers.new(picker_opts, {
      prompt_title = opts.prompt,
      previewer = false,
      finder = finders.new_table {
        results = items,
        entry_maker = entry_maker,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not selection then
            -- User did not select anything.
            on_choice(nil, nil)
            return
          end
          local idx = nil
          for i, item in ipairs(items) do
            if item == selection.value then
              idx = i
              break
            end
          end
          on_choice(selection.value, idx)
        end)

        actions.close:enhance { post = function() end }

        return true
      end,
    }):find()
  end)
end

for ui_addition, enabled in pairs(astronvim.user_plugin_opts("ui", { nui_input = true, telescope_select = true })) do
  if enabled and type(ui[ui_addition]) == "function" then
    ui[ui_addition]()
  end
end
