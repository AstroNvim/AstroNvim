local M = {}

function M.config()
  vim.g.loaded_highlighturl = true
  vim.api.nvim_create_augroup("highlighturl", {})
  vim.api.nvim_create_autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
    desc = "Set URL Highlights",
    group = "highlighturl",
    pattern = "*",
    command = "call highlighturl#set_url_match()",
  })
end

return M
