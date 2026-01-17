-- C# LSP and tooling configuration using easy-dotnet.nvim
return {
	-- easy-dotnet.nvim - Full .NET development plugin with built-in Roslyn LSP
	{
		"GustavEikaas/easy-dotnet.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local dotnet = require("easy-dotnet")
			dotnet.setup({
				lsp = {
					enabled = true,
					roslynator_enabled = true,
					analyzer_assemblies = {},
					config = {},
				},
			})

			-- Keybinding to restart Roslyn LSP (useful after solution loads)
			vim.keymap.set("n", "<leader>cr", function()
				require("easy-dotnet.roslyn.lsp").restart()
				vim.notify("Restarting Roslyn LSP...", vim.log.levels.INFO)
			end, { desc = "Restart C# LSP" })
		end,
	},

	-- Ensure C# formatter is installed
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "csharpier" })
		end,
	},

	-- NOTE: C# formatter (csharpier) is configured in custom/plugins/conform.lua

	-- Add C# to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "c_sharp" })
		end,
	},
}
