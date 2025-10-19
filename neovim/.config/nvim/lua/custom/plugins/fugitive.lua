return {
	"tpope/vim-fugitive",
	cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
	keys = {
		{ "<leader>Gs", "<cmd>Git<cr>", desc = "Git status" },
		{ "<leader>Gc", "<cmd>Git commit<cr>", desc = "Git commit" },
		{ "<leader>Gp", "<cmd>Git push<cr>", desc = "Git push" },
		{ "<leader>GP", "<cmd>Git pull<cr>", desc = "Git pull" },
		{ "<leader>Gb", "<cmd>Git blame<cr>", desc = "Git blame" },
		{ "<leader>Gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
		{ "<leader>Gl", "<cmd>Git log --oneline<cr>", desc = "Git log" },
	},
}