local now, add = MiniDeps.now, MiniDeps.add

now(function()
	add("ibhagwan/fzf-lua")
	require("fzf-lua").setup({
		winopts = {
			preview = {
				hidden = false,
				layout = "horizontal",
				horizontal = "right:45%",
			},
		},
		oldfiles = {
			include_current_session = true,
		},
		keymap = {
			builtin = {
				["<C-p>"] = "toggle-preview",
			},
		},
		previewers = {
			builtin = {
				syntax_limit_b = 1024 * 100, -- Evita highlight em arquivos >100KB no preview (Treesitter trava)
			},
		},
	})

	-- Mapeamento de teclas
	pcall(vim.keymap.del, "n", "<leader>fr")
	pcall(vim.keymap.del, "n", "<leader>fR")

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").oldfiles({ cwd = vim.uv.cwd() })
	end, { desc = "FZF: Arquivos Recentes (no diretório atual)" })

	vim.keymap.set("n", "<leader>fR", "<cmd>FzfLua oldfiles<cr>", { desc = "FZF: Arquivos Recentes (global)" })
	vim.keymap.set("n", "<leader><space>", function() require("fzf-lua").files() end, { desc = "FZF: Find Files (Root Dir)" })
end)
