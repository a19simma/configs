return {
  'rebelot/kanagawa.nvim',
  priority = 1000,
  config = function()
    require('kanagawa').setup {
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      transparent = true,
    }
    vim.cmd.colorscheme 'kanagawa'
  end,
}
