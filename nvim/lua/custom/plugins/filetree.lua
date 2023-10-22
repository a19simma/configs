return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  },
  config = function()
    vim.keymap.set("n", "<leader>ft", ":NvimTreeToggle<CR>")
    require('nvim-tree').setup {
      trash = {
        cmd = "trash",
      }
    }
  end
}
