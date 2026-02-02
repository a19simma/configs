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
