local now, later = MiniDeps.now, MiniDeps.later

now(function()
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

now(function()
	local function ai_buffer(ai_type)
		local start_line, end_line = 1, vim.fn.line("$")
		if ai_type == "i" then
			local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
			if first_nonblank == 0 or last_nonblank == 0 then
				return { from = { line = start_line, col = 1 } }
			end
			start_line, end_line = first_nonblank, last_nonblank
		end
		local to_col = math.max(vim.fn.getline(end_line):len(), 1)
		return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
	end

	require("mini.ai").setup({
		custom_textobjects = {
			g = ai_buffer,
		},
	})
end)

later(function()
	require("mini.statusline").setup()
	require("mini.icons").setup()
	require("mini.indentscope").setup({
		symbol = "│",
		draw = {
			delay = 0,
			animation = require("mini.indentscope").gen_animation.none(),
		},
	})
end)

later(function()
	local hipatterns = require("mini.hipatterns")
	hipatterns.setup({
		highlighters = {
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			-- Highlight hex color strings (`#rrggbb`) using that color
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

later(function()
	local mini_notify = require("mini.notify")
	mini_notify.setup({
		lsp_progress = {
			enable = false,
		},
	})
	vim.notify = mini_notify.make_notify()
end)

now(function()
	require("mini.trailspace").setup()
	vim.api.nvim_create_user_command("CleanWhitespace", function(opts)
		local lines_before = vim.api.nvim_buf_line_count(0)
		require("mini.trailspace").trim()
		local cmd
		if opts.range > 0 then
			cmd = string.format("silent %d,%dg/^\\s*$/d", opts.line1, opts.line2)
		else
			cmd = "silent %g/^\\s*$/d"
		end
		vim.cmd(cmd)
		local lines_after = vim.api.nvim_buf_line_count(0)
		local deleted_lines = lines_before - lines_after
		if deleted_lines > 0 then
			vim.notify(
				string.format(
					"Cleaned: removed trailing spaces + %d blank line%s",
					deleted_lines,
					deleted_lines == 1 and "" or "s"
				)
			)
		else
			vim.notify("Cleaned: removed trailing spaces (no blank lines found)")
		end
	end, {
		desc = "Remove trailing spaces e linhas em branco",
		range = true,
	})

	vim.api.nvim_create_user_command("TrimSpaces", function()
		require("mini.trailspace").trim()
		vim.notify("Trailing spaces removed")
	end, {
		desc = "Remove apenas trailing spaces",
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function()
			require("mini.trailspace").trim()
		end,
	})

	vim.api.nvim_create_user_command("DeleteBlankLines", function(opts)
		local cmd
		if opts.range > 0 then
			cmd = string.format("silent %d,%dg/^\\s*$/d", opts.line1, opts.line2)
		else
			cmd = "silent %g/^\\s*$/d"
		end
		local lines_before = vim.api.nvim_buf_line_count(0)
		vim.cmd(cmd)
		local lines_after = vim.api.nvim_buf_line_count(0)
		local deleted = lines_before - lines_after
		if deleted > 0 then
			vim.notify(string.format("Deleted %d blank line%s", deleted, deleted == 1 and "" or "s"))
		else
			vim.notify("No blank lines found", vim.log.levels.INFO)
		end
	end, {
		desc = "Remove apenas linhas em branco",
		range = true,
	})

	vim.keymap.set({ "n", "v" }, "<leader>cw", ":CleanWhitespace<CR>", { desc = "Clean whitespace" })
	vim.keymap.set({ "n", "v" }, "<leader>cb", ":DeleteBlankLines<CR>", { desc = "Delete blank lines" })
	vim.keymap.set("n", "<leader>ct", ":TrimSpaces<CR>", { desc = "Trim trailing spaces" })
end)

later(function()
	require("mini.files").setup({
		windows = {
			preview = false,
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
end)

later(function()
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
