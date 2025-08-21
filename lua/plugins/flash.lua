local now, later = MiniDeps.now, MiniDeps.later

later(function()
	MiniDeps.add("folke/flash.nvim")
	require("flash").setup({})

	local flash = require("flash")

	vim.keymap.set({ "n", "x" }, "s", "<Nop>", { noremap = true, silent = true })

	vim.keymap.set({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash: Jump" })
	vim.keymap.set({ "n", "o", "x" }, "S", function() flash.treesitter() end, { desc = "Flash: Treesitter" })
	vim.keymap.set("o", "r", function() flash.remote() end, { desc = "Flash: Remote" })
	vim.keymap.set({ "o", "x" }, "R", function() flash.treesitter_search() end, { desc = "Flash: Treesitter Search" })
	vim.keymap.set("c", "<c-s>", function() flash.toggle() end, { desc = "Flash: Toggle Search" })
end)
