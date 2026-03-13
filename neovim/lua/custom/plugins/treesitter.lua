-- Tree-sitter configuration
-- Requires Neovim 0.11.0+ and the main branch of nvim-treesitter
-- Features (highlight, fold, indent) are no longer configured via setup opts;
-- they are enabled per-filetype via autocommands per the new API.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
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
			})

			-- Enable highlighting, folding, and indentation for all filetypes
			-- that have a treesitter parser installed.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local ok = pcall(vim.treesitter.start)
					if not ok then
						return
					end
					-- Treesitter-based folding
					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					-- Treesitter-based indentation (experimental)
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- Incremental selection (removed from nvim-treesitter main branch)
	-- {
	-- 	"daliusd/incr.nvim",
	-- 	config = function()
	-- 		require("incr").setup({})
	-- 		vim.keymap.set("n", "<C-n>", function()
	-- 			require("incr").init_selection()
	-- 		end, { desc = "Treesitter: start selection" })
	-- 		vim.keymap.set("v", "<C-n>", function()
	-- 			require("incr").node_incremental()
	-- 		end, { desc = "Treesitter: expand selection" })
	-- 		vim.keymap.set("v", "<C-m>", function()
	-- 			require("incr").node_decremental()
	-- 		end, { desc = "Treesitter: shrink selection" })
	-- 	end,
	-- },
}
