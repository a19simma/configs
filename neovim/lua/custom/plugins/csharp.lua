-- C# LSP and tooling configuration
return {
	-- Add OmniSharp to mason-tool-installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "omnisharp", "csharpier" })
		end,
	},

	-- Add csharpier formatter
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.cs = { "csharpier" }
		end,
	},

	-- Add C# to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "c_sharp" })
		end,
	},
}

-- TODO: OmniSharp configuration is commented out due to lspconfig deprecation in nvim 0.11+
-- For now, manually configure in init.lua by adding omnisharp to the servers table around line 698:
--[[
omnisharp = {
	cmd = {
		"dotnet",
		vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll",
	},
	settings = {
		FormattingOptions = {
			EnableEditorConfigSupport = true,
			OrganizeImports = true,
		},
		RoslynExtensionsOptions = {
			EnableDecompilationSupport = true,
			EnableAnalyzersSupport = true,
		},
	},
	on_attach = function(client, bufnr)
		-- Disable semantic tokens (OmniSharp has issues with LSP spec compliance)
		client.server_capabilities.semanticTokensProvider = nil
	end,
},
--]]
