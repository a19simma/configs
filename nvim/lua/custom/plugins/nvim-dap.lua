return {
  'mfussenegger/nvim-dap',
  ft = { "go" },
  config = function()
    local dap = require("dap")
    vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end)
    vim.keymap.set("n", "<leader>dc", function() dap.continue() end)
    vim.keymap.set("n", "<leader>dso", function() dap.step_over() end)
    vim.keymap.set("n", "F10", function() dap.step_over() end)
    vim.keymap.set("n", "<leader>dsu", function() dap.step_out() end)
    vim.keymap.set("n", "<leader>dsi", function() dap.step_into() end)
  end
}
