local status_ok, symbolsoutline = pcall(require, "symbols-outline")
if not status_ok then return end
symbolsoutline.setup()
