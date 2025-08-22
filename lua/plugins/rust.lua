local add, later = MiniDeps.add, MiniDeps.later

add({ source = "mrcjkb/rustaceanvim", checkout = "master" })
add({ source = "Saecki/crates.nvim" })

later(function()
	require("crates").setup({
		completion = {
			crates = { enabled = true },
		},
		lsp = {
			enabled = true,
			actions = true,
			completion = true,
			hover = true,
		},
	})

	vim.g.rustaceanvim = {
		server = {
			default_settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
				},
			},
		},
	}
end)
