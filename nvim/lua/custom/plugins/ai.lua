return {
  -- {
  --   "zbirenbaum/copilot.lua",
  --   dependencies = {
  --     { "hrsh8th/nvim-cmp" },
  --     {
  --       "nvim-lualine/lualine.nvim",
  --       event = "VeryLazy",
  --     },
  --   },
  --   enabled = true,
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   build = ":Copilot auth",
  --   opts = {
  --     panel = {
  --       enabled = true,
  --       auto_refresh = false,
  --       keymap = {
  --         jump_prev = "[[",
  --         jump_next = "]]",
  --         accept = "<CR>",
  --         refresh = "gr",
  --         open = "<A-CR>"
  --       },
  --     },
  --     suggestion = {
  --       enabled = true,
  --       -- use the built-in keymapping for "accept" (<M-l>)
  --       auto_trigger = false,
  --       keymap = {
  --         accept = "<C-y>",
  --         accept_word = false,
  --         accept_line = false,
  --         next = "<C-]>",
  --         prev = "<C-[>",
  --         dismiss = "<C-u>",
  --       }
  --     },
  --     filetypes = {},
  --   },
  --   config = function(_, opts)
  --     require("copilot").setup(opts)
  --
  --     -- hide copilot suggestions when cmp menu is open
  --     -- to prevent odd behavior/garbled up suggestions
  --     local cmp_status_ok, cmp = pcall(require, "cmp")
  --     if cmp_status_ok then
  --       cmp.event:on("menu_opened", function()
  --         vim.b.copilot_suggestion_hidden = true
  --       end)
  --
  --       cmp.event:on("menu_closed", function()
  --         vim.b.copilot_suggestion_hidden = false
  --       end)
  --     end
  --   end,
  -- },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-y>",
          clear_suggestion = "<C-]>",
        }
      })
    end
  }
}
