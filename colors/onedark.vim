" Author: Kabin Karki <kabinkarki555@gmail.com>

lua << EOF

package.loaded["onedark"] = nil
package.loaded["onedark.base"] = nil
package.loaded["onedark.treesitter"] = nil
package.loaded["onedark.lsp"] = nil
package.loaded["onedark.others"] = nil

require("onedark")

EOF
