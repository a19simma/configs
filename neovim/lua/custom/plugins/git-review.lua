return {
	{
		"dlyongemallo/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
		keys = {
			{ "<leader>Gd", "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>", desc = "PR diff" },
			{ "<leader>Gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
			{ "<leader>GH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
			{ "<leader>Gx", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
		},
		opts = {
			default_args = {
				DiffviewOpen = { "--imply-local" },
			},
		},
	},
}
