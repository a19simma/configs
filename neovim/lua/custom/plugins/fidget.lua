-- Override fidget.nvim configuration for transparency
-- This overrides the default opts = {} in init.lua
return {
	"j-hui/fidget.nvim",
	opts = {
		notification = {
			window = {
				winblend = 0, -- No pseudo-transparency, rely on highlight groups
				normal_hl = "Normal", -- Use transparent Normal highlight
			},
		},
	},
}
