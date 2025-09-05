local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add({ source = "rebelot/kanagawa.nvim", checkout = "master" })
add({ source = "rose-pine/neovim" })
add({ source = "nickkadutskyi/jb.nvim" })

now(function()
	require("kanagawa").setup({
		transparent = true,
		colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
	})
	require("rose-pine").setup({
		styles = {
			transparency = true,
		},
	})
	require("jb").setup()
	vim.cmd("colorscheme kanagawa")
end)
