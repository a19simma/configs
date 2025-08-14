-- Global tab and indentation settings
vim.opt.tabstop = 2      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2   -- Number of spaces for each indentation level
vim.opt.softtabstop = 2  -- Number of spaces a tab counts for while editing
vim.opt.expandtab = true -- Convert tabs to spaces

-- Line numbers
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- Global statusline (recommended for avante.nvim)
vim.opt.laststatus = 3   -- Views can only be fully collapsed with the global statusline