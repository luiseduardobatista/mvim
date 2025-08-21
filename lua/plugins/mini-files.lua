local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.files").setup({
		windows = {
			preview = true,
			width_focus = 30,
			width_preview = 30,
		},
		options = {
			use_as_default_explorer = false,
			permanent_delete = false,
		},
		mappings = {
			go_in_plus = "l",
			go_out_plus = "h",
			toggle_hidden = "g.",
			-- Ação nativa para mudar o diretório de trabalho (CWD) para o do explorador
			reveal_cwd = "@",
			go_in_split = "<C-w>s",
			go_in_vsplit = "<C-w>v",
			go_in_split_plus = "<C-w>S",
			go_in_vsplit_plus = "<C-w>V",
		},
	})

	vim.keymap.set("n", "<leader>e", function()
		require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
	end, { desc = "Explorer: Open (Current File)" }) -- Descrição atualizada para agrupar

	-- Alterado de <leader>fM para <leader>E
	vim.keymap.set("n", "<leader>E", function()
		require("mini.files").open(vim.uv.cwd(), true)
	end, { desc = "Explorer: Open (CWD)" }) -- Descrição atualizada para agrupar
end)
