local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add({ source = "rebelot/kanagawa.nvim", checkout = "master" })
later(function()
	require("kanagawa").setup()
	vim.cmd("colorscheme kanagawa")
end)
