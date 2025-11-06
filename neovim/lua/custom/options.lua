-- Global tab and indentation settings
vim.opt.tabstop = 1      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 1   -- Number of spaces for each indentation level
vim.opt.softtabstop = 1  -- Number of spaces a tab counts for while editing
vim.opt.expandtab = true -- Convert tabs to spaces

-- Line numbers
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- Line wrapping
vim.opt.wrap = false          -- Don't wrap long lines
vim.opt.colorcolumn = "120"   -- Show guide at 120 characters

-- Global statusline
vim.opt.laststatus = 3   -- Views can only be fully collapsed with the global statusline