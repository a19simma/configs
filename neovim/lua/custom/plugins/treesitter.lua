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
			local ts = require("nvim-treesitter")

			ts.install({
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
			-- Note: YAML is excluded from treesitter indentation due to bugs
			-- with whitespace-sensitive indentation.
			local skip_indent_filetypes = {
				yaml = true,
				helm = true,
			}

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local ok = pcall(vim.treesitter.start)
					if not ok then
						return
					end
					-- Treesitter-based folding
					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					-- Treesitter-based indentation (skip for YAML/helm)
					if not skip_indent_filetypes[ev.match] then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
