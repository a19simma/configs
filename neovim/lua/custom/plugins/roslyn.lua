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
		"seblyng/roslyn.nvim",
		ft = "cs",
		-- init runs at startup, before plugin loads and before vim.lsp.enable fires,
		-- so on_attach/settings are registered before the first client starts.
		init = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end
			capabilities.workspace = capabilities.workspace or {}
			capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

			vim.lsp.config("roslyn", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					local snacks = require("snacks")
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end
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
					["csharp|formatting"] = {
						dotnet_organize_imports_on_format = true,
						dotnet_sort_system_directives_first = true,
					},
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
					["csharp|code_lens"] = {
						dotnet_enable_references_code_lens = true,
						dotnet_enable_tests_code_lens = true,
					},
					["csharp|completion"] = {
						dotnet_provide_regex_completions = true,
						dotnet_show_completion_items_from_unimported_namespaces = true,
						dotnet_show_name_completion_suggestions = true,
					},
					["csharp|symbol_search"] = {
						dotnet_search_reference_assemblies = true,
					},
					["csharp|background_analysis"] = {
						dotnet_analyzer_diagnostics_scope = "openFiles",
						dotnet_compiler_diagnostics_scope = "openFiles",
					},
				},
			})
		end,
		opts = {
			filewatching = "off",
			broad_search = false,
			silent = false,
		},
		init = function()
			vim.api.nvim_create_user_command("RoslynCleanup", function()
				vim.fn.system(
					"for d in /tmp/roslyn-canonical-misc/*/; do"
					.. " uuid=$(basename $d);"
					.. " pgrep -f $uuid > /dev/null || rm -rf $d;"
					.. " done"
				)
				vim.notify("Roslyn: cleaned up orphaned instance dirs", vim.log.levels.INFO)
			end, { desc = "Remove orphaned roslyn instance dirs from /tmp" })

			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
						local pipe = client.rpc and client.rpc.cmd and client.rpc.cmd[#client.rpc.cmd]
						if pipe then
							-- pipe arg is the named pipe path; parent dir is the instance dir
							local instance_dir = vim.fn.fnamemodify(pipe, ":h")
							if instance_dir:find("/tmp/roslyn-canonical-misc/", 1, true) then
								vim.fn.system({ "rm", "-rf", instance_dir })
							end
						end
					end
				end,
			})
		end,
	},
}
