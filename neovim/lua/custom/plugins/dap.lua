-- Debug Adapter Protocol (DAP) configuration for Neovim
-- Simple setup using js-debug-adapter from Mason
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle [B]reakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Conditional [B]reakpoint",
			},
			{
				"<leader>dc",
				function()
					if vim.bo.filetype:match("^dapui_") then
						return
					end
					require("dap").continue()
				end,
				desc = "Debug: [C]ontinue",
			},
			{
				"<leader>dC",
				function()
					local url = vim.fn.input("URL: ", "http://localhost:5173")
					vim.fn.jobstart({
						"google-chrome",
						"--remote-debugging-port=9222",
						"--user-data-dir=C:\\temp\\chrome-dap",
						"--no-first-run",
						"--no-default-browser-check",
						url,
					}, { detach = true })
					vim.defer_fn(function()
						require("dap").run({
							type = "pwa-chrome",
							request = "attach",
							name = "Launch Chrome",
							port = 9222,
							webRoot = "${workspaceFolder}",
						})
					end, 1500)
				end,
				desc = "Launch [C]hrome",
			},
			{
				"<leader>dW",
				function()
					-- Use the WSL default gateway as the Windows host IP
					local host = vim.fn.trim(vim.fn.system("ip route show default | awk '{print $3; exit}'"))
					if host == "" then
						host = "localhost"
					end
					require("dap").run({
						type = "pwa-chrome",
						request = "attach",
						name = "Attach Chrome (WSL→Windows)",
						address = host,
						port = 9222,
						webRoot = "${workspaceFolder}",
					})
				end,
				desc = "Attach Chrome ([W]SL→Windows)",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Debug: Step [I]nto",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Debug: Step [O]ver",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Debug: Step [O]ut",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle Debug [R]EPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Debug: Run [L]ast",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle Debug [U]I",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "[T]erminate Debug Session",
			},
			{
				"<leader>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Debug: [H]over Variables",
				mode = { "n", "v" },
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup DAP UI
			dapui.setup()

			-- Setup adapters using js-debug-adapter from Mason
			dap.adapters["pwa-chrome"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "js-debug-adapter",
					args = { "${port}" },
				},
			}

			-- Python adapter configuration
			dap.adapters.python = function(cb, config)
				if config.request == "launch" then
					local port = 5678
					local host = "127.0.0.1"
					cb({
						type = "server",
						port = port,
						host = host,
						executable = {
							command = "python",
							args = { "-m", "debugpy.adapter" },
						},
					})
				else
					cb({
						type = "executable",
						command = "python",
						args = { "-m", "debugpy.adapter" },
					})
				end
			end

			-- Python debug configurations
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						local cwd = vim.fn.getcwd()
						if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
							return cwd .. "/venv/bin/python"
						elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
							return cwd .. "/.venv/bin/python"
						else
							return "python"
						end
					end,
				},
			}

			-- netcoredbg adapter for C#
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			-- C# debug configurations
			local function pick_dotnet_dll()
				return coroutine.create(function(dap_run_co)
					if vim.fn.confirm("Build before debug?", "&Yes\n&No", 1) == 1 then
						vim.notify("Building...")
						local result = vim.fn.system("dotnet build -c Debug")
						if vim.v.shell_error ~= 0 then
							vim.notify("Build failed:\n" .. result, vim.log.levels.ERROR)
							coroutine.resume(dap_run_co, vim.NIL)
							return
						end
					end
					local dlls = vim.fn.globpath(vim.fn.getcwd(), "**/bin/Debug/**/*.dll", 0, 1)
					local items = vim.tbl_filter(function(p)
						return not p:match("/ref/")
					end, dlls)
					if #items == 0 then
						vim.notify("No dlls found under bin/Debug/", vim.log.levels.ERROR)
						coroutine.resume(dap_run_co, vim.NIL)
						return
					end
					vim.ui.select(items, {
						prompt = "Select dll to debug:",
						format_item = function(p)
							return vim.fn.fnamemodify(p, ":.")
						end,
					}, function(choice)
						coroutine.resume(dap_run_co, choice)
					end)
				end)
			end

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch project (build & pick)",
					request = "launch",
					program = pick_dotnet_dll,
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
				},
				{
					type = "coreclr",
					name = "Attach (pick process)",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}

			-- Chrome attach configuration for JS/TS/Svelte
		for _, language in ipairs({ "typescript", "javascript", "svelte" }) do
			dap.configurations[language] = {
				{
					type = "pwa-chrome",
					request = "attach",
					name = "Attach to Chrome",
					port = 9222,
					webRoot = "${workspaceFolder}",
				},
			}
		end

		-- Auto-open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({ reset = true })
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Breakpoint signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStopped" })

			-- Highlight groups
			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
			vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
		end,
	},

	-- Install js-debug-adapter via Mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"js-debug-adapter",
				"debugpy",
				"netcoredbg",
			})
			return opts
		end,
	},

	-- which-key group
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			spec = {
				{ "<leader>d", group = "[D]ebug", mode = { "n", "v" } },
			},
		},
	},
}
