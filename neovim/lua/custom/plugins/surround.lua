-- nvim-surround: Add/change/delete surrounding delimiter pairs with ease
-- https://github.com/kylechui/nvim-surround
return {
	"kylechui/nvim-surround",
	version = "*", -- Use latest release
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			-- Configuration options (all are optional with sensible defaults)
		})
	end,
}
