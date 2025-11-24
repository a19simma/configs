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
        -- Kubernetes - yamlls has built-in content-based detection (looks for apiVersion/kind)
        -- Only add explicit patterns if you need to override
        -- kubernetes = '*.k8s.yaml',

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

        -- OpenAPI/Swagger specifications (SchemaStore.nvim already provides these)
        -- Uncomment if you need custom patterns:
        -- ['https://json.schemastore.org/openapi-3.1.json'] = 'openapi*.{yml,yaml}',
        -- ['https://json.schemastore.org/swagger-2.0.json'] = 'swagger*.{yml,yaml}',

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

      -- Lua Language Server Configuration
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      }
      vim.lsp.enable({ 'lua_ls' })

      -- TypeScript/JavaScript Language Server Configuration
      vim.lsp.config.ts_ls = {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'javascript', 'typescript' },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      }
      vim.lsp.enable({ 'ts_ls' })

      -- Svelte Language Server Configuration
      vim.lsp.config.svelte = {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'svelte' },
        settings = {
          svelte = {
            plugin = {
              typescript = {
                enable = true,
              },
            },
          },
        },
      }
      vim.lsp.enable({ 'svelte' })

      -- Helper function to set LSP keymaps (shared across all servers)
      local function on_attach(client, bufnr)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        -- LSP Keymaps (using snacks.picker for navigation)
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('grr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
        map('gri', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
        map('grd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', function() Snacks.picker.lsp_symbols() end, 'Document [S]ymbols')
        map('gW', function() Snacks.picker.lsp_workspace_symbols() end, 'Workspace [S]ymbols')
        map('grt', function() Snacks.picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')
      end

      -- Go Language Server Configuration
      vim.lsp.config.gopls = {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            staticcheck = true,
            gofumpt = true,
            -- Semantic tokens for better syntax highlighting
            semanticTokens = true,
            -- Enable all code lenses
            codelenses = {
              gc_details = true,
              generate = true,
              regenerate_cgo = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            -- Improved completion
            usePlaceholders = true,
            completeUnimported = true,
            -- Build flags
            buildFlags = { '-tags=integration' },
            -- Enable detailed hover information
            hoverKind = 'FullDocumentation',
            linkTarget = 'pkg.go.dev',
            -- Inlay hints
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      }
      vim.lsp.enable({ 'gopls' })

      -- Rust Language Server Configuration
      vim.lsp.config.rust_analyzer = {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
            },
            cargo = {
              allFeatures = true,
            },
            inlayHints = {
              lifetimeElisionHints = {
                enable = 'skip_trivial',
              },
            },
          },
        },
      }
      vim.lsp.enable({ 'rust_analyzer' })

      -- Python Language Server Configuration
      vim.lsp.config.pyright = {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
              typeCheckingMode = 'basic',
            },
          },
        },
      }
      vim.lsp.enable({ 'pyright' })

      -- C/C++ Language Server Configuration
      vim.lsp.config.clangd = {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
      }
      vim.lsp.enable({ 'clangd' })

      -- C# Language Server Configuration
      vim.lsp.config.omnisharp = {
        capabilities = capabilities,
        cmd = {
          'dotnet',
          vim.fn.stdpath 'data' .. '/mason/packages/omnisharp/libexec/OmniSharp.dll',
        },
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          RoslynExtensionsOptions = {
            EnableDecompilationSupport = true,
            EnableAnalyzersSupport = true,
          },
        },
        on_attach = function(client, bufnr)
          -- Set up standard LSP keymaps first
          on_attach(client, bufnr)

          -- Disable semantic tokens (OmniSharp has issues with LSP spec compliance)
          if client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      }
      vim.lsp.enable({ 'omnisharp' })

      -- YAML Language Server Configuration
      vim.lsp.config.yamlls = {
        capabilities = capabilities,
        on_attach = on_attach,
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
      vim.lsp.enable({ 'yamlls' })

      -- Helm Language Server Configuration
      -- helm-ls: 358 stars, actively maintained, supports Helm charts + K8s schemas
      vim.lsp.config.helm_ls = {
        capabilities = capabilities,
        on_attach = on_attach,
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
      vim.lsp.enable({ 'helm_ls' })

      -- Markdown Language Server (Marksman)
      -- marksman: 2.8k stars, actively maintained, latest release Dec 2024
      -- Provides completion, goto definition, find references, rename, diagnostics
      -- Supports wiki-link style references for note-taking
      vim.lsp.config.marksman = {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'markdown', 'markdown.mdx' },
      }
      vim.lsp.enable({ 'marksman' })

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
        'lua-language-server', -- lua_ls
        'typescript-language-server', -- ts_ls
        'svelte-language-server', -- svelte
        'gopls', -- Go
        'rust-analyzer', -- Rust
        'pyright', -- Python
        'clangd', -- C/C++
        'omnisharp', -- C#
        'yaml-language-server', -- yamlls
        'helm-ls', -- Helm language server
        'marksman', -- Markdown LSP
      })
      return opts
    end,
  },
}
