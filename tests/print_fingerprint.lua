local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path
local root = vim.fs.dirname(tests_dir)
io.stdout:write(require("test_environment").compatibility_fingerprint(root) .. "\n")
