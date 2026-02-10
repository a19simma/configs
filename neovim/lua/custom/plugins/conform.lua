return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = 'Format buffer',
    },
    {
      '<leader>cF',
      function()
        -- Full C# format with analyzers (slow but complete)
        if vim.bo.filetype == 'cs' then
          local conform = require('conform')
          conform.format({ 
            formatters = { 'csharp_format_full' }, 
            async = true,
            timeout_ms = 60000, -- 60 seconds for full format
          })
        else
          require('conform').format { async = true, lsp_format = 'fallback' }
        end
      end,
      mode = '',
      desc = 'Format buffer (C#: full)',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true, cs = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters = {
      -- Fast: Use dotnet format whitespace (respects .editorconfig)
      ['csharp_format'] = {
        command = 'dotnet',
        args = function(self, ctx)
          -- Find project root manually
          local root = vim.fs.find(function(name)
            return name:match('%.sln$') or name:match('%.slnx$') or name:match('%.csproj$')
          end, { upward = true, path = ctx.dirname })[1]
          
          if root then
            root = vim.fn.fnamemodify(root, ':h')
          end
          
          local relative_path = ctx.filename
          if root then
            relative_path = vim.fn.substitute(ctx.filename, '^' .. vim.fn.escape(root, '/') .. '/', '', '')
          end
          
          return {
            'format',
            'whitespace',
            '--folder',
            '--include',
            relative_path,
          }
        end,
        stdin = false,
        cwd = function(self, ctx)
          local root = vim.fs.find(function(name)
            return name:match('%.sln$') or name:match('%.slnx$') or name:match('%.csproj$')
          end, { upward = true, path = ctx.dirname })[1]
          
          if root then
            return vim.fn.fnamemodify(root, ':h')
          end
          return nil
        end,
      },
      -- Slow but complete: Full format with style and analyzers
      ['csharp_format_full'] = {
        command = 'dotnet',
        args = function(self, ctx)
          -- Use roslyn.nvim's selected solution
          local sln_file = vim.g.roslyn_nvim_selected_solution
          
          if not sln_file then
            vim.notify('No solution selected. Roslyn may not be initialized yet.', vim.log.levels.WARN)
            return nil
          end
          
          local root = vim.fn.fnamemodify(sln_file, ':h')
          local sln_name = vim.fn.fnamemodify(sln_file, ':t')
          
          local relative_path = vim.fn.substitute(ctx.filename, '^' .. vim.fn.escape(root, '/') .. '/', '', '')
          
          return {
            'format',
            sln_name,
            '--include',
            relative_path,
            '--no-restore',
            '--verbosity',
            'quiet',
          }
        end,
        stdin = false,
        timeout_ms = 60000, -- Force 60s timeout
        cwd = function(self, ctx)
          local sln_file = vim.g.roslyn_nvim_selected_solution
          if sln_file then
            return vim.fn.fnamemodify(sln_file, ':h')
          end
          return nil
        end,
      },
    },
    formatters_by_ft = {
      -- Lua
      lua = { 'stylua' },

      -- Go
      go = { 'gofumpt', 'goimports-reviser', 'golines' },

      -- Rust
      rust = { 'rustfmt' },

      -- Python
      python = { 'black', 'isort' },

      -- JavaScript/TypeScript
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      svelte = { 'prettierd', 'prettier', stop_after_first = true },

      -- C/C++/C#
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      cs = { 'csharp_format' }, -- Uses dotnet format whitespace (respects .editorconfig)

      -- Web formats
      json = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },

      -- Shell
      sh = { 'shfmt' },
      bash = { 'shfmt' },
    },
  },
  },

  -- Install formatters via Mason
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'stylua', -- Lua
        'gofumpt', -- Go
        'goimports-reviser', -- Go imports
        'golines', -- Go line length
        'rustfmt', -- Rust (usually comes with rust toolchain)
        'black', -- Python
        'isort', -- Python imports
        'prettierd', -- JavaScript/TypeScript/Web (faster prettier)
        'clang-format', -- C/C++
        'shfmt', -- Shell scripts
      })
      return opts
    end,
  },
}
