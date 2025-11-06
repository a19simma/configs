return {
	"milanglacier/minuet-ai.nvim",
	dependencies = { "saghen/blink.cmp" },
	config = function()
		require("minuet").setup({
			provider = "openai_fim_compatible",
			-- Context window (7B model can handle ~4K efficiently)
			context_window = 4096,
			-- Number of completion candidates
			n_completions = 1,
			provider_options = {
				openai_fim_compatible = {
					model = "qwen2.5-coder:7b",
					end_point = "http://localhost:11434/v1/completions",
					name = "Ollama",
					api_key = "TERM", -- Ollama doesn't need authentication
					stream = true,
					optional = {
						stop = nil, -- Let Ollama handle stop tokens
						max_tokens = 128, -- Max tokens to generate (tune this for completion length)
						temperature = 0.3,
						top_p = 0.9,
					},
				},
			},
		})
	end,
}
