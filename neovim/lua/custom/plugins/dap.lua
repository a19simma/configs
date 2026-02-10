-- Debug Adapter Protocol (DAP) configuration for Neovim
-- Simple setup using js-debug-adapter from Mason
-- Server-side debugging only (use Chrome DevTools for client-side)
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle [B]reakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional [B]reakpoint" },
			{ 
				"<leader>dc", 
				function()
					if vim.bo.filetype:match("^dapui_") then return end
					require("dap").continue()
				end, 
				desc = "Debug: [C]ontinue" 
			},
			{ "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step [I]nto" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "Debug: Step [O]ver" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "Debug: Step [O]ut" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle Debug [R]EPL" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run [L]ast" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle Debug [U]I" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "[T]erminate Debug Session" },
			{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug: [H]over Variables", mode = { "n", "v" } },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup DAP UI
			dapui.setup()

		-- Setup adapters using js-debug-adapter from Mason
		-- Note: Mason's js-debug-adapter uses DAP debug server, not VSCode debug server
		for _, adapter in pairs({ "pwa-node", "pwa-chrome" }) do
			dap.adapters[adapter] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "js-debug-adapter",
					args = { "${port}" },
				},
			}
		end

		-- Configure debug configurations for JavaScript/TypeScript/Svelte
		local js_based_languages = { "typescript", "javascript", "svelte" }

		for _, language in ipairs(js_based_languages) do
			dap.configurations[language] = {
				-- Server-side: Attach to running Node process
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to Node Process",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
				},
				-- Server-side: Launch a single file
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
				},
			-- Client-side: Launch Chrome (minimal config)
			{
				type = "pwa-chrome",
				request = "launch",
				name = "Launch Chrome",
				url = "http://localhost:5173",
				webRoot = function()
					return vim.fn.getcwd()
				end,
			},
			-- WSL: Launch Chrome helper (runs script then attaches)
			{
				type = "pwa-chrome",
				request = "attach",
				name = "Launch Chrome (WSL)",
				port = 9222,
				webRoot = function()
					return vim.fn.getcwd()
				end,
				sourceMaps = true,
				-- Source map path overrides for common build tools
				sourceMapPathOverrides = {
					["webpack:///./*"] = "${webRoot}/*",
					["webpack://?:*/*"] = "${webRoot}/*",
					["webpack:///*"] = "*",
					["webpack:///./~/*"] = "${webRoot}/node_modules/*",
					["meteor://💻app/*"] = "${webRoot}/*",
				},
				-- This will be triggered by a custom command
				-- Use :DapLaunchChrome instead of selecting this directly
			},
			-- WSL: Attach to Chrome running in Windows
			-- Instructions:
			--   1. From Windows PowerShell: .\Start-ChromeDebug.ps1
			--      (Script located at: \\wsl$\Ubuntu\home\simon\repos\configs\wsl-scripts\Start-ChromeDebug.ps1)
			--   2. Or manually run: 
			--      & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\temp\chrome-debug" http://localhost:5173
			--   3. Then use this attach configuration
			{
				type = "pwa-chrome",
				request = "attach",
				name = "Attach to Chrome (WSL)",
				port = 9222,
				webRoot = function()
					return vim.fn.getcwd()
				end,
				sourceMaps = true,
				-- Source map path overrides for common build tools
				sourceMapPathOverrides = {
					["webpack:///./*"] = "${webRoot}/*",
					["webpack://?:*/*"] = "${webRoot}/*",
					["webpack:///*"] = "*",
					["webpack:///./~/*"] = "${webRoot}/node_modules/*",
					["meteor://💻app/*"] = "${webRoot}/*",
				},
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

			-- Custom command: Launch Chrome and attach (WSL)
			vim.api.nvim_create_user_command("DapLaunchChrome", function()
				-- Kill existing Chrome
				print("Stopping existing Chrome instances...")
				vim.fn.system('powershell.exe -Command "Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue"')
				vim.wait(500)
				
				-- Launch Chrome with debugging
				print("Launching Chrome with debugging on port 9222...")
				vim.fn.jobstart(
					'powershell.exe -Command "& \\"C:\\\\Program Files\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe\\" --remote-debugging-port=9222 --user-data-dir=\\"C:\\\\temp\\\\chrome-debug\\" --no-first-run --no-default-browser-check http://localhost:5173"',
					{ detach = true }
				)
				
				-- Wait for Chrome to start
				print("Waiting for Chrome to start...")
				vim.wait(3000)
				
				-- Verify debug server is ready
				local result = vim.fn.system('curl -s http://localhost:9222/json/version')
				if result:match("Browser") then
					print("✓ Chrome debug server ready! Starting DAP...")
					-- Find and run the "Attach to Chrome (WSL)" configuration
					local configs = dap.configurations[vim.bo.filetype] or {}
					for _, config in ipairs(configs) do
						if config.name == "Attach to Chrome (WSL)" then
							dap.run(config)
							return
						end
					end
					print("Error: Could not find 'Attach to Chrome (WSL)' configuration")
				else
					print("✗ Chrome debug server not responding. Try manually: :DapLaunchChrome")
				end
			end, {desc = "Launch Chrome with debugging and attach DAP (WSL)"})
		end,
	},

	-- Install js-debug-adapter via Mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"js-debug-adapter",
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
