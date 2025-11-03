-- Override lint configuration to disable markdown linting
return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		-- Remove markdown linting to avoid permission errors
		lint.linters_by_ft = lint.linters_by_ft or {}
		lint.linters_by_ft.markdown = nil
	end,
}