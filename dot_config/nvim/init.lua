-- Neovim IDE Configuration
-- Leader key setup (Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Compatibility shim for Neovim 0.10+ / 0.12+ ft_to_lang removal
if vim.treesitter.ft_to_lang == nil and vim.treesitter.language then
  vim.treesitter.ft_to_lang = vim.treesitter.language.get_lang
end

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.lazy")
