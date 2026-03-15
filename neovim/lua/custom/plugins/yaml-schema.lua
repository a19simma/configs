return {
  -- SchemaStore.nvim provides a collection of JSON schemas for various file types
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },

  -- Auto-detect YAML schemas, including CRDs from current kubectl context
  -- https://github.com/cwrau/yaml-schema-detect.nvim
  {
    "cwrau/yaml-schema-detect.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "yaml", "helm" },
    opts = {
      keymap = {
        refresh = "<leader>xr", -- Refresh schema detection
        cleanup = "<leader>xyc", -- Clean up schema cache
        info = "<leader>xyi", -- Show schema info
      },
    },
  },

  -- Treesitter support for YAML and Helm templates
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end

      -- Add YAML and Go template parsers for Helm support
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "yaml", "gotmpl" })
      end

      return opts
    end,
  },
}