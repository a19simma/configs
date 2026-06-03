return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts.registries = opts.registries or {}
			table.insert(opts.registries, "github:mason-org/mason-registry")
			table.insert(opts.registries, "github:Crashdummyy/mason-registry")
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "roslyn" })
			return opts
		end,
	},

	{
		"seblyng/roslyn.nvim",
		ft = "cs",
		init = function()
			-- Capabilities: disable dynamic file watching (roslyn registers too many)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end
			capabilities.workspace = capabilities.workspace or {}
			capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

			vim.lsp.config("roslyn", {
				capabilities = capabilities,
				cmd_env = { DOTNET_USE_POLLING_FILE_WATCHER = "1" },
				on_attach = function(_, bufnr)
					local snacks = require("snacks")
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("grr", function() snacks.picker.lsp_references() end, "[G]oto [R]eferences")
					map("gri", function() snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
					map("grd", function() snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gO",  function() snacks.picker.lsp_symbols() end, "Document [S]ymbols")
					map("gW",  function() snacks.picker.lsp_workspace_symbols() end, "Workspace [S]ymbols")
					map("grt", function() snacks.picker.lsp_type_definitions() end, "[G]oto [T]ype Definition")
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

			local function kill_roslyn_processes()
				-- Kill dotnet processes running the Roslyn language server
				vim.fn.system("pkill -f 'Microsoft.CodeAnalysis.LanguageServer' 2>/dev/null")
				-- Clean up orphaned instance dirs (no matching live process)
				vim.fn.system(
					"for d in /tmp/roslyn-canonical-misc/*/; do"
					.. " [ -d \"$d\" ] || continue;"
					.. " uuid=$(basename \"$d\");"
					.. " pgrep -f \"$uuid\" > /dev/null || rm -rf \"$d\";"
					.. " done"
				)
			end

			-- Extend :Lsp with a 'log' subcommand; delegate the rest to neovim's built-in ex_cmd
			local ex_cmd = require("vim._core.ex_cmd")
			vim.api.nvim_create_user_command("Lsp", function(args)
				local fargs = args.fargs
				local subcmd = fargs[1]
				if subcmd == "log" then
					local filter = fargs[2]
					local log_path = vim.lsp.get_log_path()
					if not filter then
						vim.cmd("tabnew " .. log_path)
						return
					end
					local lines = vim.fn.readfile(log_path)
					local filtered = vim.tbl_filter(function(l)
						return l:lower():find(filter:lower(), 1, true) ~= nil
					end, lines)
					local buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered)
					vim.bo[buf].filetype = "log"
					vim.bo[buf].modifiable = false
					vim.bo[buf].bufhidden = "wipe"
					vim.api.nvim_buf_set_name(buf, "lsp log: " .. filter)
					vim.cmd("tabnew")
					vim.api.nvim_win_set_buf(0, buf)
					vim.cmd("normal! G")
				else
					ex_cmd.ex_lsp(args.args)
				end
			end, {
				nargs = "+",
				complete = function(arglead, cmdline, _)
					local split = vim.split(cmdline, "%s+")
					if #split <= 2 then
						local subcmds = vim.list_extend({ "log" }, ex_cmd.lsp_complete(cmdline))
						return vim.tbl_filter(function(s) return s:find(arglead, 1, true) == 1 end, subcmds)
					elseif split[2] == "log" then
						return vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())
					else
						return ex_cmd.lsp_complete(cmdline)
					end
				end,
				desc = "LSP subcommands: enable/disable/restart/stop/log [server]",
			})

			vim.api.nvim_create_user_command("RoslynCleanup", function()
				kill_roslyn_processes()
				vim.notify("Roslyn: killed orphaned processes and cleaned instance dirs", vim.log.levels.INFO)
			end, { desc = "Kill orphaned roslyn/dotnet processes and clean /tmp instance dirs" })

			-- On exit: stop attached clients gracefully then force-kill any remaining process
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
						client.stop(true)
					end
					kill_roslyn_processes()
				end,
			})
		end,
		opts = {
			filewatching = "off",
			broad_search = false,
			silent = false,
		},
	},
}
