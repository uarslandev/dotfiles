-- Neovim IDE Configuration
-- Leader key setup (Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.lazy")
