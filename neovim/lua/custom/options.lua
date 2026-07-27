-- Global tab and indentation settings
vim.opt.tabstop = 4      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4   -- Number of spaces for each indentation level
vim.opt.softtabstop = 4  -- Number of spaces a tab counts for while editing
vim.opt.expandtab = true -- Convert tabs to spaces

-- Line numbers
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- Line wrapping
vim.opt.wrap = false        -- Don't wrap long lines
vim.opt.colorcolumn = "120" -- Show guide at 120 characters

-- Global statusline
vim.opt.laststatus = 3 -- Views can only be fully collapsed with the global statusline

-- Start with all folds open
vim.opt.foldlevel = 99

vim.opt.autoindent = true

-- Avoid btrfs transaction-commit freezes: keep Neovim's fsync/volatile state off btrfs.
-- swapsync="" stops the per-change swapfile fsync that stalls the whole desktop.
vim.opt.fsync = false                    -- don't fsync written files
vim.opt.directory = "/dev/shm/nvim/swap//" -- swapfiles on tmpfs (RAM) -> no btrfs commit on swap writes
vim.opt.undodir = "/dev/shm/nvim/undo//"   -- persistent undo on tmpfs
vim.opt.shadafile = "/dev/shm/nvim/main.shada"

-- Ensure the tmpfs dirs exist (tmpfs is wiped on reboot)
vim.fn.mkdir("/dev/shm/nvim/swap", "p")
vim.fn.mkdir("/dev/shm/nvim/undo", "p")
