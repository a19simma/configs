return {
  'mfussenegger/nvim-dap',
  keys = {
    {
      "<leader>b",
      "<cmd>DapToggleBreakpoint<CR>",
      desc =
      "Toggle breakpoint"
    },
    {
      "<leader>dc",
      "<cmd>DapContinue<CR>",
      desc =
      "Continue debugger"
    },
    {
      "<F10>",
      "<cmd>DapStepOver<CR>",
      desc =
      "Step Over"
    },
    {
      "<F11>",
      "<cmd>DapStepInto<CR>",
      desc = "StepInto"
    },
    {
      "<F12>",
      "<cmd>DapStepOut<CR>",
      desc = "StepOut"
    }
  },
}
