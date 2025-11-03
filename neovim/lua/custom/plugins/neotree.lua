return {
	"nvim-neo-tree/neo-tree.nvim",
	keys = {
		{ "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
		{ "<leader>fr", "<cmd>Neotree reveal<cr>", desc = "Reveal file in tree" },
	},
	init = function()
		-- Disable netrw (neovim's default file explorer)
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- Open neo-tree when vim starts with a directory argument
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function(data)
				local directory = vim.fn.isdirectory(data.file) == 1
				if directory then
					vim.cmd.cd(data.file)
					require("neo-tree.command").execute({ action = "show" })
				end
			end,
		})
	end,
	opts = {
		filesystem = {
			hijack_netrw_behavior = "open_default", -- open neo-tree in side panel when opening a directory
		},
	},
}