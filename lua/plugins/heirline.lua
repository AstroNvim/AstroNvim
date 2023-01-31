return {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  opts = function()
    --- a submodule of heirline specific functions and aliases
    astronvim.status.heirline = {}

    --- A helper function to get the type a tab or buffer is
    -- @param self the self table from a heirline component function
    -- @param prefix the prefix of the type, either "tab" or "buffer" (Default: "buffer")
    -- @return the string of prefix with the type (i.e. "_active" or "_visible")
    function astronvim.status.heirline.tab_type(self, prefix)
      local tab_type = ""
      if self.is_active then
        tab_type = "_active"
      elseif self.is_visible then
        tab_type = "_visible"
      end
      return (prefix or "buffer") .. tab_type
    end

    --- Make a list of buffers, rendering each buffer with the provided component
    ---@param component table
    ---@return table
    astronvim.status.heirline.make_buflist = function(component)
      local overflow_hl = astronvim.status.hl.get_attributes("buffer_overflow", true)
      return require("heirline.utils").make_buflist(
        astronvim.status.utils.surround(
          "tab",
          function(self)
            return {
              main = astronvim.status.heirline.tab_type(self) .. "_bg",
              left = "tabline_bg",
              right = "tabline_bg",
            }
          end,
          { -- bufferlist
            init = function(self) self.tab_type = astronvim.status.heirline.tab_type(self) end,
            on_click = { -- add clickable component to each buffer
              callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
              minwid = function(self) return self.bufnr end,
              name = "heirline_tabline_buffer_callback",
            },
            { -- add buffer picker functionality to each buffer
              condition = function(self) return self._show_picker end,
              update = false,
              init = function(self)
                if not (self.label and self._picker_labels[self.label]) then
                  local bufname = astronvim.status.provider.filename()(self)
                  local label = bufname:sub(1, 1)
                  local i = 2
                  while label ~= " " and self._picker_labels[label] do
                    if i > #bufname then break end
                    label = bufname:sub(i, i)
                    i = i + 1
                  end
                  self._picker_labels[label] = self.bufnr
                  self.label = label
                end
              end,
              provider = function(self)
                return astronvim.status.provider.str { str = self.label, padding = { left = 1, right = 1 } }
              end,
              hl = astronvim.status.hl.get_attributes "buffer_picker",
            },
            component, -- create buffer component
          },
          false -- disable surrounding
        ),
        { provider = astronvim.get_icon "ArrowLeft" .. " ", hl = overflow_hl },
        { provider = astronvim.get_icon "ArrowRight" .. " ", hl = overflow_hl },
        function() return vim.t.bufs end, -- use astronvim bufs variable
        false -- disable internal caching
      )
    end

    --- Alias to require("heirline.utils").make_tablist
    astronvim.status.heirline.make_tablist = require("heirline.utils").make_tablist

    --- Run the buffer picker and execute the callback function on the selected buffer
    -- @param callback function with a single parameter of the buffer number
    function astronvim.status.heirline.buffer_picker(callback)
      local tabline = require("heirline").tabline
      local buflist = tabline and tabline._buflist[1]
      if buflist then
        local prev_showtabline = vim.opt.showtabline:get()
        buflist._picker_labels = {}
        buflist._show_picker = true
        if prev_showtabline ~= 2 then vim.opt.showtabline = 2 end
        vim.cmd.redrawtabline()
        local char = vim.fn.getcharstr()
        local bufnr = buflist._picker_labels[char]
        if bufnr then callback(bufnr) end
        buflist._show_picker = false
        if prev_showtabline ~= 2 then vim.opt.showtabline = prev_showtabline end
        vim.cmd.redrawtabline()
      end
    end

    return {
      statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        astronvim.status.component.mode(),
        astronvim.status.component.git_branch(),
        astronvim.status.component.file_info { filetype = {}, filename = false, file_modified = false },
        astronvim.status.component.git_diff(),
        astronvim.status.component.diagnostics(),
        astronvim.status.component.fill(),
        astronvim.status.component.cmd_info(),
        astronvim.status.component.fill(),
        astronvim.status.component.lsp(),
        astronvim.status.component.treesitter(),
        astronvim.status.component.nav(),
        astronvim.status.component.mode { surround = { separator = "right" } },
      },
      winbar = { -- winbar
        static = {
          disabled = {
            buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
            filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
          },
        },
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        {
          condition = function(self)
            return vim.opt.diff:get() or astronvim.status.condition.buffer_matches(self.disabled or {})
          end,
          init = function() vim.opt_local.winbar = nil end,
        },
        astronvim.status.component.file_info {
          condition = function() return not astronvim.status.condition.is_active() end,
          unique_path = {},
          file_icon = { hl = astronvim.status.hl.file_icon "winbar" },
          file_modified = false,
          file_read_only = false,
          hl = astronvim.status.hl.get_attributes("winbarnc", true),
          surround = false,
          update = "BufEnter",
        },
        astronvim.status.component.breadcrumbs { hl = astronvim.status.hl.get_attributes("winbar", true) },
      },
      tabline = { -- bufferline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            return astronvim.status.condition.buffer_matches(
              { filetype = { "aerial", "dapui_.", "neo%-tree", "NvimTree" } },
              vim.api.nvim_win_get_buf(self.winid)
            )
          end,
          provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
          hl = { bg = "tabline_bg" },
        },
        astronvim.status.heirline.make_buflist(astronvim.status.component.tabline_file_info()), -- component for each buffer tab
        astronvim.status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          astronvim.status.heirline.make_tablist { -- component for each tab
            provider = astronvim.status.provider.tabnr(),
            hl = function(self)
              return astronvim.status.hl.get_attributes(astronvim.status.heirline.tab_type(self, "tab"), true)
            end,
          },
          { -- close button for current tab
            provider = astronvim.status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
            hl = astronvim.status.hl.get_attributes("tab_close", true),
            on_click = { callback = astronvim.close_tab, name = "heirline_tabline_close_tab_callback" },
          },
        },
      },
      statuscolumn = vim.fn.has "nvim-0.9" == 1 and {
        astronvim.status.component.foldcolumn(),
        astronvim.status.component.fill(),
        astronvim.status.component.numbercolumn(),
        astronvim.status.component.signcolumn(),
      } or nil,
    }
  end,
  config = require "plugins.configs.heirline",
}
