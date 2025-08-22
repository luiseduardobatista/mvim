local later = MiniDeps.later

later(function()
	require("mini.statusline").setup()
end)

later(function()
	require("mini.icons").setup()
end)

later(function()
	require("mini.indentscope").setup({ symbol = "│" })
end)

later(function()
	require("mini.notify").setup({
		lsp_progress = {
			enable = false,
		},
	})
end)
