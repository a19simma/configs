-- Configure minuet for manual trigger only (based on official docs)
return {
	"saghen/blink.cmp",
	opts = function(_, opts)
		-- Add custom keybind for AI completion (merges with existing preset from init.lua)
		opts.keymap['<C-k>'] = require('minuet').make_blink_map()

		-- Configure minuet provider (don't add to default sources to keep LSP auto-complete working)
		opts.sources.providers.minuet = {
			name = 'minuet',
			module = 'minuet.blink',
			async = true,
			timeout_ms = 3000,
			score_offset = 100,
		}

		-- Show more lines in completion documentation window
		opts.completion.documentation.window = opts.completion.documentation.window or {}
		opts.completion.documentation.window.max_height = 30
		opts.completion.documentation.window.max_width = 80

		return opts
	end,
}

