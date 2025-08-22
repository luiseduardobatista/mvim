local add, later = MiniDeps.add, MiniDeps.later

add({
	source = "linux-cultist/venv-selector.nvim",
	checkout = "regexp",
	depends = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
})

later(function()
	require("venv-selector").setup({
		options = {
			notify_user_on_venv_activation = true,
			picker = "telescope",
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function()
			vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<cr>", {
				desc = "Select VirtualEnv",
				buffer = true,
			})
		end,
	})
end)
