" Author: Kabin Karki <kabinkarki555@gmail.com>

lua << EOF

package.loaded["default_theme"] = nil
package.loaded["default_theme.base"] = nil
package.loaded["default_theme.treesitter"] = nil
package.loaded["default_theme.lsp"] = nil
package.loaded["default_theme.others"] = nil

require("default_theme")

EOF
