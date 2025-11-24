return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
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
      cs = { 'csharpier' },

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
        'csharpier', -- C#
        'shfmt', -- Shell scripts
      })
      return opts
    end,
  },
}
