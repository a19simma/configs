return {
	"milanglacier/minuet-ai.nvim",
	-- Only enable if ANTHROPIC_API_KEY is set
	enabled = vim.fn.getenv("ANTHROPIC_API_KEY") ~= vim.NIL,
	opts = {
		-- Provider configuration
		provider = "claude",
		provider_options = {
			claude = {
				model = "claude-haiku-4-5-20251001",
				temperature = 0.3,
				max_tokens = 512,
				stream = true,
				-- Read API key from environment variable
				api_key = vim.fn.getenv("ANTHROPIC_API_KEY"),
			},
		},
	},
}
