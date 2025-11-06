-- Enhanced diagnostic viewing configuration
return {
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      -- Fuzzy search Neovim messages
      {
        '<leader>sm',
        function()
          -- Get all messages
          local messages = vim.split(vim.fn.execute 'messages', '\n')

          -- Use Telescope to fuzzy search messages
          require('telescope.pickers').new({}, {
            prompt_title = 'Neovim Messages',
            finder = require('telescope.finders').new_table {
              results = messages,
            },
            sorter = require('telescope.config').values.generic_sorter {},
            previewer = false,
            attach_mappings = function(_, map)
              -- Copy selected message on <C-y>
              map('i', '<C-y>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                vim.fn.setreg('+', selection.value)
                vim.notify('Message copied to clipboard', vim.log.levels.INFO)
              end)
              return true
            end,
          }):find()
        end,
        desc = '[S]earch [M]essages',
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Show full diagnostic on current line in floating window (press gl)
      vim.keymap.set('n', 'gl', function()
        vim.diagnostic.open_float {
          border = 'rounded',
          source = 'always',
          max_width = 100,
          max_height = 30,
          wrap = true,
          focus = true, -- Focus the floating window so you can scroll
        }
      end, { desc = 'Show [L]ine diagnostics in float' })

      -- Copy diagnostic message to clipboard (press <leader>dy)
      vim.keymap.set('n', '<leader>dy', function()
        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
        if #diagnostics > 0 then
          local messages = {}
          for _, diag in ipairs(diagnostics) do
            table.insert(messages, string.format('[%s] %s', diag.source or 'LSP', diag.message))
          end
          local text = table.concat(messages, '\n\n')
          vim.fn.setreg('+', text)
          vim.notify('Diagnostic copied to clipboard', vim.log.levels.INFO)
        else
          vim.notify('No diagnostics on current line', vim.log.levels.WARN)
        end
      end, { desc = '[D]iagnostic [Y]ank (copy)' })

      -- Jump to next/previous diagnostic with auto-preview in float
      vim.keymap.set('n', ']d', function()
        vim.diagnostic.goto_next { float = { border = 'rounded', max_width = 100 } }
      end, { desc = 'Next diagnostic' })

      vim.keymap.set('n', '[d', function()
        vim.diagnostic.goto_prev { float = { border = 'rounded', max_width = 100 } }
      end, { desc = 'Previous diagnostic' })
    end,
  },

  -- Trouble.nvim - Better diagnostic list viewer (alternative to Telescope)
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    opts = {
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
    },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
    },
  },
}
