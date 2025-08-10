return {
	"yetone/avante.nvim",
	build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	opts = {
		provider = "claude",
		auto_suggestions_provider = "gemini_flash", -- Use faster model for suggestions
		behaviour = {
			auto_suggestions = true,
			enable_fastapply = true, -- Enable Fast Apply feature
		},
		web_search_engine = {
			provider = "tavily", -- tavily, serpapi, google, kagi, brave, or searxng
			proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
		},
		suggestion = {
			debounce = 600, -- Faster triggering (default 600)
			throttle = 600, -- Faster throttling (default 600)
		},
		mappings = {
			suggestion = {
				accept = "<M-a>",
			},
		},
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				timeout = 30000, -- Timeout in milliseconds
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 20480,
				},
			},
			claude_haiku = {
				__inherited_from = "claude",
				model = "claude-3-5-haiku-20241022", -- Fast model for suggestions
				timeout = 10000,
				extra_request_body = {
					temperature = 0.5,
					max_tokens = 4096,
				},
			},
			gemini = {
				model = "gemini-pro",
			},
			gemini_flash = {
				__inherited_from = "gemini",
				model = "gemini-2.5-flash-lite", -- Very fast model
				timeout = 10000,
				extra_request_body = {
					temperature = 0.5,
					maxOutputTokens = 4096,
				},
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
}
