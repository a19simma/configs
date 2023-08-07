return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap" },
  ft = { "go" },
  config = function()
    require('dapui').setup()
    vim.keymap.set("n", "<leader>du", function() require('dapui').toggle() end)
  end
}
