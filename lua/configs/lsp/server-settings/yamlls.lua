local opts = {
  settings = {
    yaml = {
      schemas = require("schemastore").json.schemas(),
    },
  },
}

return opts
