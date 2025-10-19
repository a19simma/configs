--[[
return {
	"milanglacier/minuet-ai.nvim",
	enabled = false,
	-- Hello
	opts = {
		-- Provider configuration
		provider = "gemini",
		provider_options = {
			claude = {
				model = "claude-sonnet-4-20250514",
				temperature = 0.3,
				max_tokens = 512,
				stream = true,
			},
			gemini = {
				model = "gemini-2.0-flash",
				temperature = 0.3,
				max_tokens = 512,
				stream = true,
			},
		},
	},
}
--]]

return {}
