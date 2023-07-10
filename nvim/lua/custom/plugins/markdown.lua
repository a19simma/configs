return {
  "iamcco/markdown-preview.nvim",
  ft = "markdown",
  keys = {
    { "<C-p>", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle MarkdownPreviewToggle" }
  },
  build = function() vim.fn["mkdp#util#install"]() end
}
