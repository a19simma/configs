-- Roslyn LSP for C# (.NET)
-- roslyn.nvim: Microsoft's official Roslyn language server for Neovim
-- Provides advanced C# features: IntelliSense, refactoring, code lens, analyzers, etc.
return {
	-- First, we need to add the custom mason registry for roslyn
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts.registries = opts.registries or {}
			table.insert(opts.registries, "github:mason-org/mason-registry")
			table.insert(opts.registries, "github:Crashdummyy/mason-registry")
		end,
	},

	-- Install roslyn via mason-tool-installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"roslyn", -- Roslyn language server for C#
			})
			return opts
		end,
	},

	-- Roslyn.nvim plugin
	{
		"seblj/roslyn.nvim",
		ft = "cs", -- Only load for C# files
		opts = {
			-- Plugin options (different from LSP config)
			filewatching = "auto",
			broad_search = false,
			silent = false,
		},
		config = function(_, opts)
			-- Setup the plugin
			require("roslyn").setup(opts)

		-- Configure LSP settings using vim.lsp.config as a FUNCTION
		vim.lsp.config("roslyn", {
			on_attach = function(client, bufnr)
					-- Set up LSP keymaps (same as other LSP servers)
					local snacks = require("snacks")
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end

					-- LSP Keymaps (using snacks.picker for navigation)
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("grr", function()
						snacks.picker.lsp_references()
					end, "[G]oto [R]eferences")
					map("gri", function()
						snacks.picker.lsp_implementations()
					end, "[G]oto [I]mplementation")
					map("grd", function()
						snacks.picker.lsp_definitions()
					end, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gO", function()
						snacks.picker.lsp_symbols()
					end, "Document [S]ymbols")
					map("gW", function()
						snacks.picker.lsp_workspace_symbols()
					end, "Workspace [S]ymbols")
					map("grt", function()
						snacks.picker.lsp_type_definitions()
					end, "[G]oto [T]ype Definition")
				end,
			settings = {
				-- Enable formatting (respects .editorconfig)
				["csharp|formatting"] = {
					dotnet_organize_imports_on_format = true,
					dotnet_sort_system_directives_first = true,
				},
				-- Enable inlay hints for better type visibility
					["csharp|inlay_hints"] = {
						csharp_enable_inlay_hints_for_implicit_object_creation = true,
						csharp_enable_inlay_hints_for_implicit_variable_types = true,
						csharp_enable_inlay_hints_for_lambda_parameter_types = true,
						csharp_enable_inlay_hints_for_types = true,
						dotnet_enable_inlay_hints_for_indexer_parameters = true,
						dotnet_enable_inlay_hints_for_literal_parameters = true,
						dotnet_enable_inlay_hints_for_object_creation_parameters = true,
						dotnet_enable_inlay_hints_for_other_parameters = true,
						dotnet_enable_inlay_hints_for_parameters = true,
						dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
						dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
						dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
					},
					-- Enable code lens for references
					["csharp|code_lens"] = {
						dotnet_enable_references_code_lens = true,
						dotnet_enable_tests_code_lens = true,
					},
					-- Enable completion settings
					["csharp|completion"] = {
						dotnet_provide_regex_completions = true,
						dotnet_show_completion_items_from_unimported_namespaces = true,
						dotnet_show_name_completion_suggestions = true,
					},
					-- Symbol search settings
					["csharp|symbol_search"] = {
						dotnet_search_reference_assemblies = true,
					},
				},
			})
		end,
	},
}
