local now, add = MiniDeps.now, MiniDeps.add

now(function()
	add("ibhagwan/fzf-lua")
	local fzf_config = require("fzf-lua").config
	fzf_config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
	fzf_config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
	fzf_config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
	fzf_config.defaults.actions.files["ctrl-r"] = function(_, ctx)
		local o = vim.deepcopy(ctx.__call_opts)
		o.cwd_only = not o.cwd_only
		require("fzf-lua").files(o)
	end
	require("fzf-lua").config.set_action_helpstr(fzf_config.defaults.actions.files["ctrl-r"], "toggle-root-dir")
	local img_previewer
	for _, v in ipairs({
		{ cmd = "ueberzug", args = {} },
		{ cmd = "chafa", args = { "{file}", "--format=symbols" } },
		{ cmd = "viu", args = { "-b" } },
	}) do
		if vim.fn.executable(v.cmd) == 1 then
			img_previewer = vim.list_extend({ v.cmd }, v.args)
			break
		end
	end
	local opts = {
		profiles = {
			["default-title"] = {
				prompt = " ",
				winopts = {
					title = " " .. "FZF" .. " ",
					title_pos = "center",
				},
			},
		},
		fzf_colors = true,
		defaults = {
			profile = "default-title",
			formatter = "path.dirname_first",
		},
		winopts = {
			width = 0.8,
			height = 0.8,
			row = 0.5,
			col = 0.5,
			preview = {
				hidden = false,
				layout = "horizontal",
				horizontal = "right:45%",
				scrollchars = { "┃", "" },
			},
		},
		previewers = {
			builtin = {
				syntax_limit_b = 1024 * 100,
				extensions = {
					["png"] = img_previewer,
					["jpg"] = img_previewer,
					["jpeg"] = img_previewer,
					["gif"] = img_previewer,
					["webp"] = img_previewer,
				},
				ueberzug_scaler = "fit_contain",
			},
		},
		files = {
			cwd_prompt = false,
		},
		lsp = {
			symbols = {
				child_prefix = false,
			},
		},
		oldfiles = {
			include_current_session = true,
		},
	}
	opts = vim.tbl_deep_extend("force", require("fzf-lua.profiles.default-title"), opts)
	require("fzf-lua").setup(opts)
	local function ui_select_handler(ui_opts, items)
		return vim.tbl_deep_extend("force", ui_opts, {
			prompt = " ",
			winopts = {
				title = " " .. vim.trim((ui_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
				title_pos = "center",
				width = 0.5,
				height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
			},
		})
	end
	require("fzf-lua").register_ui_select(ui_select_handler)
	vim.ui.select = require("fzf-lua").ui_select
	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").oldfiles({ cwd = vim.uv.cwd() })
	end, { desc = "FZF: Arquivos Recentes (cwd)" })
	vim.keymap.set("n", "<leader>fR", "<cmd>FzfLua oldfiles<cr>", { desc = "FZF: Arquivos Recentes (global)" })
	vim.keymap.set("n", "<leader><space>", function()
		require("fzf-lua").files()
	end, { desc = "FZF: Procurar Arquivos (Raiz)" })
	vim.keymap.set("n", "<leader>/", function()
		require("fzf-lua").live_grep()
	end, { desc = "FZF: Grep (Raiz)" })
	vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "FZF: Histórico de Comandos" })
	vim.keymap.set(
		"n",
		"<leader>fb",
		"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
		{ desc = "FZF: Buffers" }
	)
	vim.keymap.set("n", "<leader>ff", function()
		require("fzf-lua").files()
	end, { desc = "FZF: Procurar Arquivos (Raiz)" })
	vim.keymap.set("n", "<leader>fF", function()
		require("fzf-lua").files({ cwd_only = true })
	end, { desc = "FZF: Procurar Arquivos (cwd)" })
	vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "FZF: Arquivos Git" })
	vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "FZF: Commits" })
	vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "FZF: Git Status" })
	vim.keymap.set("n", '<leader>s"', "<cmd>FzfLua registers<cr>", { desc = "FZF: Registradores" })
	vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", { desc = "FZF: Grep no Buffer Atual" })
	vim.keymap.set("n", "<leader>sh", "<cmd>FzfLua help_tags<cr>", { desc = "FZF: Help Tags" })
	vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "FZF: Mapeamentos de Teclas" })
	vim.keymap.set("n", "<leader>sM", "<cmd>FzfLua man_pages<cr>", { desc = "FZF: Man Pages" })
	vim.keymap.set("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "FZF: Resumir Última Busca" })
	vim.keymap.set("n", "<leader>sw", function()
		require("fzf-lua").grep_cword()
	end, { desc = "FZF: Grep Palavra (Raiz)" })
	vim.keymap.set("n", "<leader>sW", function()
		require("fzf-lua").grep_cword({ cwd_only = true })
	end, { desc = "FZF: Grep Palavra (cwd)" })
	vim.keymap.set("v", "<leader>sw", function()
		require("fzf-lua").grep_visual()
	end, { desc = "FZF: Grep Seleção (Raiz)" })
	vim.keymap.set("v", "<leader>sW", function()
		require("fzf-lua").grep_visual({ cwd_only = true })
	end, { desc = "FZF: Grep Seleção (cwd)" })
	vim.keymap.set("n", "<leader>ss", function()
		require("fzf-lua").lsp_document_symbols()
	end, { desc = "FZF: Símbolos do Documento" })
	vim.keymap.set("n", "<leader>sS", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, { desc = "FZF: Símbolos do Workspace" })
end)
