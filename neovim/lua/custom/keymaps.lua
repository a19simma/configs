-- Custom keymaps
vim.keymap.set("n", "<leader>r", ":e<CR>", { desc = "Reload buffer" })

-- Gitsigns hunk viewing (lazy-require so it works before the plugin attaches)
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hi", function()
	require("gitsigns").preview_hunk_inline()
end, { desc = "Preview hunk inline" })
vim.keymap.set("n", "]c", function()
	require("gitsigns").nav_hunk("next")
end, { desc = "Next hunk" })
vim.keymap.set("n", "[c", function()
	require("gitsigns").nav_hunk("prev")
end, { desc = "Prev hunk" })

-- Gitsigns blame
vim.keymap.set("n", "<leader>tb", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle line blame" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line popup" })
vim.keymap.set("n", "<leader>hB", function()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "gitsigns-blame" then
			vim.api.nvim_win_close(win, true)
			return
		end
	end
	require("gitsigns").blame()
end, { desc = "Toggle file blame" })
