---@class AstroNvimOpts
---@field mapleader string? the leader key to map before setting up Lazy
---@field icons_enabled boolean? whether to enable icons, default to `true`
---@field pin_plugins boolean? whether to pin plugins or not, if `nil` then will pin if version is set.

---@type AstroNvimOpts
return {
  mapleader = " ",
  icons_enabled = true,
}
