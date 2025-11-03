return {
  -- SchemaStore.nvim provides a collection of JSON schemas for various file types
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
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

  --[[
  -- Kubernetes-specific enhancements
  {
    "someone-stole-my-name/yaml-companion.nvim",
    enabled = false, -- Disabled due to lspconfig deprecation in nvim 0.11+
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("yaml_schema")

      local cfg = require("yaml-companion").setup({
        -- Built in file matchers
        builtin_matchers = {
          kubernetes = { enabled = true },
          cloud_init = { enabled = false },
        },

        -- Custom matchers for plain Kubernetes manifests
        schemas = {
          -- Core Kubernetes schemas
          {
            name = "Kubernetes 1.29",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.0-standalone-strict/all.json",
          },
          {
            name = "Kubernetes 1.28",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.0-standalone-strict/all.json",
          },

          -- Crossplane schemas
          {
            name = "Crossplane Configuration",
            uri = "https://raw.githubusercontent.com/crossplane/crossplane/master/cluster/crds/apiextensions.crossplane.io_configurations.yaml",
          },
          {
            name = "Crossplane CompositeResourceDefinition",
            uri = "https://raw.githubusercontent.com/crossplane/crossplane/master/cluster/crds/apiextensions.crossplane.io_compositeresourcedefinitions.yaml",
          },
          {
            name = "Crossplane Composition",
            uri = "https://raw.githubusercontent.com/crossplane/crossplane/master/cluster/crds/apiextensions.crossplane.io_compositions.yaml",
          },
          {
            name = "Crossplane Provider",
            uri = "https://raw.githubusercontent.com/crossplane/crossplane/master/cluster/crds/pkg.crossplane.io_providers.yaml",
          },

          -- Popular CRDs and operators
          {
            name = "Argo CD Application",
            uri = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/application-crd.yaml",
          },
          {
            name = "Argo CD AppProject",
            uri = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/appproject-crd.yaml",
          },
          {
            name = "Cert-Manager Certificate",
            uri = "https://raw.githubusercontent.com/cert-manager/cert-manager/master/deploy/crds/crd-certificates.yaml",
          },
          {
            name = "Cert-Manager Issuer",
            uri = "https://raw.githubusercontent.com/cert-manager/cert-manager/master/deploy/crds/crd-issuers.yaml",
          },
          {
            name = "Prometheus ServiceMonitor",
            uri = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml",
          },

          -- Build tools
          {
            name = "Kustomization",
            uri = "https://json.schemastore.org/kustomization.json",
          },
          {
            name = "Skaffold",
            uri = "https://json.schemastore.org/skaffold.json",
          },
        },

        -- Auto-detect schemas based on content and file patterns
        patterns = {
          -- Plain Kubernetes manifests
          {
            regex = ".*\\.ya?ml$",
            priority = -1, -- Lower priority, will be overridden by more specific patterns
          },
          -- Crossplane files
          {
            regex = ".*crossplane.*\\.ya?ml$",
            priority = 10,
          },
          {
            regex = ".*composition.*\\.ya?ml$",
            priority = 10,
          },
          {
            regex = ".*xrd.*\\.ya?ml$",
            priority = 10,
          },
        },

        -- Pass any additional options that will be merged in the final LSP config
        lspconfig = {
          flags = {
            debounce_text_changes = 150,
          },
        },
      })

      require("lspconfig")["yamlls"].setup(cfg)

      -- Add keymap for changing YAML schema
      vim.keymap.set("n", "<leader>ys", "<cmd>Telescope yaml_schema<cr>", { desc = "[Y]AML [S]chema selector" })
    end,
  },
  --]]
}