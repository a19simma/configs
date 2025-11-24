return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable big file handling
    bigfile = { enabled = true },

    -- Startup dashboard
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup' },
      },
    },

    -- Indent guides (replaces indent-blankline)
    indent = {
      enabled = true,
      animate = {
        enabled = false, -- Disable animation for better performance
      },
    },

    -- Notification system
    notifier = {
      enabled = true,
      timeout = 3000,
    },

    -- Quick file operations
    quickfile = { enabled = true },

    -- Enhanced statuscolumn
    statuscolumn = { enabled = true },

    -- Word highlighting under cursor
    words = { enabled = true },

    -- Smooth scrolling
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 150 },
      },
    },

    -- Zen mode
    zen = { enabled = true },

    -- Terminal integration
    terminal = { enabled = true },

    -- LazyGit integration
    lazygit = { enabled = true },

    -- File explorer (replaces neo-tree)
    explorer = {
      enabled = true,
    },

    -- Toggle utilities
    toggle = { enabled = true },

    -- Dim inactive windows
    dim = { enabled = false }, -- Disabled by default, can be distracting

    -- Scratch buffers
    scratch = { enabled = true },

    -- Picker (fuzzy finder)
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            -- Use <C-n> and <C-p> for navigation in addition to arrow keys
            ['<C-n>'] = { 'list_down', mode = { 'n', 'i' } },
            ['<C-p>'] = { 'list_up', mode = { 'n', 'i' } },
          },
        },
      },
    },
  },

  keys = {
    -- Dashboard
    { '<leader>.',  function() Snacks.dashboard() end, desc = 'Dashboard' },

    -- File explorer
    { '<leader>e',  function() Snacks.explorer() end, desc = 'Explorer' },
    { '<leader>ft', function() Snacks.explorer() end, desc = 'Toggle file tree' },

    -- Terminal
    { '<leader>tt', function() Snacks.terminal() end, desc = 'Toggle terminal' },
    { '<c-\\>',     function() Snacks.terminal() end, desc = 'Toggle terminal', mode = { 'n', 't' } },

    -- LazyGit
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { '<leader>gl', function() Snacks.lazygit.log() end, desc = 'Lazygit log' },
    { '<leader>gf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit current file history' },

    -- Notifications
    { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss all notifications' },
    { '<leader>nh', function() Snacks.notifier.show_history() end, desc = 'Notification history' },

    -- Zen mode
    { '<leader>z',  function() Snacks.zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>Z',  function() Snacks.zen.zoom() end, desc = 'Toggle Zoom' },

    -- Scratch buffers
    { '<leader>bs', function() Snacks.scratch() end, desc = 'Toggle scratch buffer' },
    { '<leader>bS', function() Snacks.scratch.select() end, desc = 'Select scratch buffer' },

    -- Git browse
    { '<leader>gb', function() Snacks.gitbrowse() end, desc = 'Git browse', mode = { 'n', 'v' } },

    -- Toggle features
    { '<leader>td', function() Snacks.toggle.dim():toggle() end, desc = 'Toggle dim' },
    { '<leader>ts', function() Snacks.toggle.scroll():toggle() end, desc = 'Toggle scroll animation' },
  },

  init = function()
    -- Set up snacks.nvim to override vim.notify with snacks notifier
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for easy access
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks debugger
      end,
    })

    -- Make explorer and floating windows transparent - set after colorscheme loads
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        -- Main floating window transparency
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', ctermbg = 'NONE' })

        -- Clear backgrounds for all snacks-related windows
        local transparent_groups = {
          'SnacksNormal',
          'SnacksNormalNC',
          'SnacksBorder',
          'SnacksBackdrop',
          'SnacksNotifierBorder',
          'SnacksNotifierInfo',
          'SnacksNotifierWarn',
          'SnacksNotifierError',
          'SnacksNotifierDebug',
          'SnacksNotifierTrace',
        }

        for _, group in ipairs(transparent_groups) do
          vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
        end
      end,
    })

    -- Trigger once on startup
    vim.schedule(function()
      vim.cmd('doautocmd ColorScheme')
    end)
  end,
}
