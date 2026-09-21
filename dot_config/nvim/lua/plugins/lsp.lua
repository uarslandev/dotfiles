-- Map Ansible playbooks/roles to the yaml.ansible filetype so the
-- ansible-language-server (ansiblels) attaches alongside yamlls.
do
  local ansible_keys = {
    "hosts", "tasks", "roles", "become", "become_user", "become_method",
    "gather_facts", "pre_tasks", "post_tasks", "handlers", "vars_files",
    "import_playbook", "collections", "module_defaults",
  }

  local function looks_like_ansible(path, bufnr)
    if path:match("[/\\](playbook|site|workstation|sync|install)[^/\\]*%.ya?ml$") then
      return true
    end
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(64, vim.api.nvim_buf_line_count(bufnr)), false)
    for _, line in ipairs(lines) do
      local key = line:match("^%s*-?%s*([%w_]+):")
      if key and vim.tbl_contains(ansible_keys, key) then
        return true
      end
    end
    return false
  end

  vim.filetype.add({
    extension = {
      yml = function(path, bufnr)
        return looks_like_ansible(path, bufnr) and "yaml.ansible" or "yaml"
      end,
      yaml = function(path, bufnr)
        return looks_like_ansible(path, bufnr) and "yaml.ansible" or "yaml"
      end,
    },
  })
end

return {
  -- Mason LSP & Tool Installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",
          "ansiblels",
          "bashls",
          "pyright",
          "yamlls",
        },
        automatic_installation = true,
      })

      local servers = { "lua_ls", "ansiblels", "bashls", "pyright", "yamlls" }

      for _, server in ipairs(servers) do
        local server_config = { capabilities = capabilities }
        if server == "yamlls" then
          server_config.filetypes = { "yaml", "yaml.ansible", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" }
        end
        if vim.lsp.config then
          vim.lsp.config[server] = server_config
          vim.lsp.enable(server)
        else
          local ok, lspconfig = pcall(require, "lspconfig")
          if ok and lspconfig[server] then
            lspconfig[server].setup(server_config)
          end
        end
      end

      -- LSP Keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
