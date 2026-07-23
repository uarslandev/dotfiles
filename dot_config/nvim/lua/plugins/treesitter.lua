return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end
      configs.setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "bash",
          "python",
          "go",
          "yaml",
          "json",
          "dockerfile",
          "terraform",
          "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
