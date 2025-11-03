-- Additional LSP server configurations
-- This file configures yamlls, helm-ls, and marksman LSP servers
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'b0o/SchemaStore.nvim', -- JSON schema catalog (925 stars, actively maintained)
    },
    config = function()
      -- Get capabilities from blink.cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if pcall(require, 'blink.cmp') then
        capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
      end

      -- Get SchemaStore schemas
      local schemastore_ok, schemastore = pcall(require, 'schemastore')
      local schemas = schemastore_ok and schemastore.yaml.schemas() or {}

      -- Add additional schemas for common use cases
      local additional_schemas = {
        -- Kubernetes - content-based detection (yamlls looks for apiVersion/kind)
        -- This works for any K8s manifest regardless of filename (deployment.yaml, service.yaml, etc.)
        kubernetes = '*.yaml',

        -- ArgoCD CRDs
        ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json'] = {
          '**/argocd/*.yaml',
          '**/*application*.yaml',
        },
        ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/appproject_v1alpha1.json'] = {
          '**/argocd/*.yaml',
          '**/*appproject*.yaml',
        },
        ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/applicationset_v1alpha1.json'] = {
          '**/argocd/*.yaml',
          '**/*applicationset*.yaml',
        },

        -- Crossplane CRDs
        ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/apiextensions.crossplane.io/composition_v1.json'] = {
          '**/crossplane/*.yaml',
          '**/*composition*.yaml',
        },
        ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/apiextensions.crossplane.io/compositeresourcedefinition_v1.json'] = {
          '**/crossplane/*.yaml',
          '**/*xrd*.yaml',
          '**/*compositeresourcedefinition*.yaml',
        },

        -- OpenAPI/Swagger specifications
        ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = {
          'openapi*.{yml,yaml}',
          '**/openapi.{yml,yaml}',
          'swagger*.{yml,yaml}',
        },

        -- Docker Compose
        ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
          'docker-compose*.{yml,yaml}',
          'compose*.{yml,yaml}',
        },

        -- GitHub Actions
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
      }

      -- Merge additional schemas with SchemaStore
      for schema, pattern in pairs(additional_schemas) do
        schemas[schema] = pattern
      end

      -- YAML Language Server Configuration
      require('lspconfig').yamlls.setup {
        capabilities = capabilities,
        settings = {
          yaml = {
            format = { enable = true },
            telemetry = { enabled = false },
            validate = true,
            hover = true,
            completion = true,
            schemaStore = {
              -- Disable built-in schemaStore, use SchemaStore.nvim instead
              enable = false,
              url = '',
            },
            schemas = schemas,
          },
        },
      }

      -- Helm Language Server Configuration
      -- helm-ls: 358 stars, actively maintained, supports Helm charts + K8s schemas
      require('lspconfig').helm_ls.setup {
        capabilities = capabilities,
        settings = {
          ['helm-ls'] = {
            yamlls = {
              enabled = true,
              path = 'yaml-language-server',
            },
          },
        },
        filetypes = { 'helm' },
      }

      -- Markdown Language Server (Marksman)
      -- marksman: 2.8k stars, actively maintained, latest release Dec 2024
      -- Provides completion, goto definition, find references, rename, diagnostics
      -- Supports wiki-link style references for note-taking
      require('lspconfig').marksman.setup {
        capabilities = capabilities,
        filetypes = { 'markdown', 'markdown.mdx' },
      }

      -- YAML Schema Picker
      -- When you press <leader>ys in a YAML file, this will show you available schemas
      -- Selecting one adds a modeline comment like: # yaml-language-server: $schema=<url>
      local function yaml_schema_picker()
        -- Build a list of schemas with their URLs
        local schema_list = {}

        for schema_key, patterns in pairs(schemas) do
          -- Only include schemas that have a URL
          if type(schema_key) == 'string' and schema_key:match('^https?://') then
            local pattern_str = type(patterns) == 'table' and table.concat(patterns, ', ') or tostring(patterns)

            -- Extract a friendly name from the URL
            local name = schema_key:match('/([^/]+)%.json$') or schema_key:match('/([^/]+)$') or schema_key

            table.insert(schema_list, {
              display = string.format('%s (%s)', name, pattern_str),
              name = name,
              uri = schema_key,
            })
          end
        end

        -- Sort alphabetically by display name
        table.sort(schema_list, function(a, b)
          return a.display < b.display
        end)

        -- Show picker
        vim.ui.select(schema_list, {
          prompt = 'Select YAML Schema:',
          format_item = function(item)
            return item.display
          end,
        }, function(choice)
          if choice and choice.uri then
            local bufnr = vim.api.nvim_get_current_buf()

            -- Check if yamlls is attached
            local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'yamlls' }
            if #clients == 0 then
              vim.notify('yamlls not attached to this buffer', vim.log.levels.WARN)
              return
            end

            -- Add schema modeline to the top of the file
            local modeline = string.format('# yaml-language-server: $schema=%s', choice.uri)

            -- Check if first line is already a schema modeline
            local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
            if first_line:match('^# yaml%-language%-server:') then
              -- Replace existing modeline
              vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { modeline })
              vim.notify('Updated schema to: ' .. choice.name, vim.log.levels.INFO)
            else
              -- Insert new modeline at top
              vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { modeline })
              vim.notify('Added schema: ' .. choice.name, vim.log.levels.INFO)
            end
          end
        end)
      end

      -- Add keymap for YAML schema picker (only in YAML files)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'yaml',
        callback = function()
          vim.keymap.set('n', '<leader>ys', yaml_schema_picker, {
            buffer = true,
            desc = '[Y]AML [S]chema picker',
          })
        end,
      })
    end,
  },

  -- Install LSP servers via Mason
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'yaml-language-server', -- yamlls
        'helm-ls', -- Helm language server
        'marksman', -- Markdown LSP
      })
      return opts
    end,
  },
}
