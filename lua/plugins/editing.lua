local now, later = MiniDeps.now, MiniDeps.later

now(function()
	require("mini.ai").setup()
end)
now(function()
	require("mini.comment").setup()
end)
now(function()
	require("mini.move").setup()
end)
now(function()
	require("mini.pairs").setup()
end)
now(function()
	require("mini.splitjoin").setup()
end)
now(function()
	require("mini.surround").setup({
		mappings = {
			add = "gsa",
			delete = "gsd",
			find = "gsf",
			find_left = "gsF",
			highlight = "gsh",
			replace = "gsr",
			update_n_lines = "gsn",
		},
	})
end)
