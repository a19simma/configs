return {
  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    keys = {
      { "<leader>ts", "<cmd>TailwindSort<CR>",          desc = "Sort tailwind classes" },
      { "<leader>tc", "<cmd>TailwindConcealToggle<CR>", desc = "Conceal tailwind classes" },
    }
  }
}
