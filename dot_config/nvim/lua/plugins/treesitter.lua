return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
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
