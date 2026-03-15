-- LuaSnip configuration: Load custom snippets only (minimal)
-- https://github.com/L3MON4D3/LuaSnip
return {
	"L3MON4D3/LuaSnip",
	event = "InsertEnter",
	opts = function()
		local ls = require("luasnip")
		local types = require("luasnip.util.types")

		-- Only load custom VSCode JSON snippets from your snippets/ directory
		-- Comment this out if you don't want any VSCode-style snippets
		require("luasnip.loaders.from_vscode").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})

		-- Also load Lua-style snippets from custom directory (if you have any)
		-- Structure: snippets/lua/*.lua, snippets/go/*.lua, etc.
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})

		-- Configure LuaSnip
		ls.config.set_config({
			-- Enable continuous expansion
			enable_autosnippets = true,
			-- Update lazy load on TextChanged
			delete_check_events = "TextChanged",
			-- Use friendly visual indicators
			region_check_events = "ModeChanged",
		})

		-- Keybinds for snippet navigation (fallback when blink.cmp not active)
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			else
				return "<Tab>"
			end
		end, { silent = true, expr = true, desc = "Expand snippet / jump forward" })

		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			else
				return "<S-Tab>"
			end
		end, { silent = true, expr = true, desc = "Jump backward" })

		vim.keymap.set({ "i", "s" }, "<C-Tab>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true, desc = "Next snippet choice" })

		-- Print loaded snippets info (debug)
		vim.keymap.set("n", "<leader>ss", function()
			local available = ls.available()
			local count = 0
			for _, _ in pairs(available) do
				count = count + 1
			end
			print("LuaSnip: " .. count .. " snippet files loaded")
		end, { desc = "Show loaded snippets info" })
	end,
}
