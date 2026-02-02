return {
	"milanglacier/minuet-ai.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("minuet").setup({
			provider = "openai_fim_compatible",
			n_completions = 1, -- recommend for local model for resource saving
			context_window = 512,

		-- Enable virtual text for inline ghost text display
		virtualtext = {
			auto_trigger_ft = {}, -- Disabled by default, toggle with <leader>la
			keymap = {
				accept = "<C-l>", -- Ctrl+L to accept
				prev = "<C-p>",
				next = "<C-n>",
				dismiss = "<C-h>", -- Ctrl+H to dismiss
			},
		},

			provider_options = {
				openai_fim_compatible = {
					api_key = "TERM",
					name = "Ollama",
					end_point = "http://localhost:11434/v1/completions",
					model = "qwen2.5-coder:7b",
					optional = {
						max_tokens = 56,
						top_p = 0.9,
					},
				},
			},
		})

		-- Toggle auto-suggestions: <leader>la
		vim.keymap.set("n", "<leader>la", function()
			vim.cmd("Minuet virtualtext toggle")
		end, { desc = "Toggle AI auto-suggestions" })
	end,
}
