local now, later = MiniDeps.now, MiniDeps.later

now(function()
	require("mini.ai").setup()
	require("mini.comment").setup()
	require("mini.move").setup()
	require("mini.pairs").setup()
	require("mini.splitjoin").setup()
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

later(function()
	require("mini.statusline").setup()
	require("mini.icons").setup()
	require("mini.indentscope").setup({ symbol = "│" })
	require("mini.notify").setup({
		lsp_progress = {
			enable = false,
		},
	})

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
		if vim.bo.filetype == "oil" then
			return
		end
		require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
	end, { desc = "Explorer: Open (Current File)" })
	vim.keymap.set("n", "<leader>E", function()
		if vim.bo.filetype == "oil" then
			return
		end
		require("mini.files").open(vim.uv.cwd(), true)
	end, { desc = "Explorer: Open (CWD)" })

	local miniclue = require("mini.clue")
	miniclue.setup({
		triggers = {
			-- Leader triggers
			{ mode = "n", keys = "<Leader>" },
			{ mode = "x", keys = "<Leader>" },
			-- Built-in completion
			{ mode = "i", keys = "<C-x>" },
			-- `g` key
			{ mode = "n", keys = "g" },
			{ mode = "x", keys = "g" },
			-- Marks
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "`" },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "`" },
			-- Registers
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = '"' },
			{ mode = "i", keys = "<C-r>" },
			{ mode = "c", keys = "<C-r>" },
			-- Window commands
			{ mode = "n", keys = "<C-w>" },
			-- `z` key
			{ mode = "n", keys = "z" },
			{ mode = "x", keys = "z" },
		},
		window = {
			delay = 200,
			config = {
				width = "auto",
				border = "double",
			},
		},
		clues = {
			miniclue.gen_clues.builtin_completion(),
			-- miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.windows(),
			miniclue.gen_clues.z(),
		},
	})
end)
