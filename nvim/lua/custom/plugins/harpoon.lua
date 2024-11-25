return {
  'ThePrimeagen/harpoon',
  lazy = false,
  keys = {
    { "<leader>hm", function() return require("harpoon.ui").toggle_quick_menu() end, desc = "Toggle Harpoon Menu" }
  },
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>m", mark.add_file)
    vim.keymap.set("n", "<leader>hca", mark.clear_all)
    vim.keymap.set("n", "<C-h>", ui.toggle_quick_menu)

    vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
    vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
    vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
    vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
  end,
}
