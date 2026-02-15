-- Tree-sitter configuration
-- This overrides the treesitter config in init.lua
return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		opts = {
			-- Ensure these parsers are installed
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"c_sharp",
				"diff",
				"go",
				"html",
				"javascript",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"rust",
				"svelte",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			},
			-- Don't auto-install parsers (install explicitly via :TSInstall)
			auto_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = { "ruby" },
			},
			-- Incremental selection based on the named nodes from the grammar
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-n>",
					node_incremental = "<C-n>",
					scope_incremental = "<C-s>",
					node_decremental = "<C-m>",
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
