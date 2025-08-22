local add, now = MiniDeps.add, MiniDeps.now

now(function()
	add("ibhagwan/fzf-lua")

	local fzf = require("fzf-lua")

	local function get_image_previewer()
		local previewers = {
			{ cmd = "ueberzug", args = {} },
			{ cmd = "chafa", args = { "{file}", "--format=symbols" } },
			{ cmd = "viu", args = { "-b" } },
		}
		for _, p in ipairs(previewers) do
			if vim.fn.executable(p.cmd) == 1 then
				return vim.list_extend({ p.cmd }, p.args)
			end
		end
		return nil
	end

	-- Ação customizada para alternar entre diretório raiz e atual (cwd)
	local toggle_root_dir_action = function(_, ctx)
		local o = vim.deepcopy(ctx.__call_opts)
		o.cwd_only = not o.cwd_only
		fzf.files(o)
	end
	-- Define o texto de ajuda para a ação
	fzf.config.set_action_helpstr(toggle_root_dir_action, "toggle-root-dir")

	fzf.setup({
		profiles = {
			["default-title"] = {
				prompt = " ",
				winopts = {
					title = " FZF ",
					title_pos = "center",
				},
			},
		},

		fzf_colors = true,

		defaults = {
			profile = "default-title",
			formatter = "path.dirname_first",
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
					["ctrl-u"] = "half-page-up",
					["ctrl-d"] = "half-page-down",
				},
			},
			actions = {
				files = {
					["ctrl-r"] = toggle_root_dir_action,
				},
			},
		},
		winopts = {
			width = 0.8,
			height = 0.8,
			row = 0.5,
			col = 0.5,
			preview = {
				hidden = true,
				layout = "horizontal",
				horizontal = "right:45%",
				scrollchars = { "┃", "" },
			},
		},
		previewers = {
			builtin = {
				syntax_limit_b = 1024 * 100, -- 100KB
				extensions = {
					["png"] = get_image_previewer(),
					["jpg"] = get_image_previewer(),
					["jpeg"] = get_image_previewer(),
					["gif"] = get_image_previewer(),
					["webp"] = get_image_previewer(),
				},
				ueberzug_scaler = "fit_contain",
			},
		},
		files = {
			cwd_prompt = false,
		},
		oldfiles = {
			include_current_session = true,
		},
		lsp = {
			symbols = {
				child_prefix = false,
			},
		},
		keymap = {
			builtin = {
				["<C-p>"] = "toggle-preview",
			},
		},
	})

	-- Substitui o vim.ui.select padrão pelo do fzf-lua
	local function ui_select_handler(ui_opts, items)
		return vim.tbl_deep_extend("force", ui_opts, {
			prompt = " ",
			winopts = {
				title = " " .. vim.trim((ui_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
				title_pos = "center",
				width = 0.5,
				height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
			},
		})
	end
	fzf.register_ui_select(ui_select_handler)
	vim.ui.select = fzf.ui_select

	local map = vim.keymap.set
	local fzf_map = function(keys, func, desc, opts)
		opts = opts or {}
		opts.desc = "FZF: " .. desc
		map("n", keys, func, opts)
	end
	local fzf_map_v = function(keys, func, desc, opts)
		opts = opts or {}
		opts.desc = "FZF: " .. desc
		map("v", keys, func, opts)
	end

	-- Arquivos, Buffers e Recentes
	fzf_map("<leader><space>", function()
		fzf.files()
	end, "Procurar Arquivos (Raiz)")
	fzf_map("<leader>fF", function()
		fzf.files({ cwd_only = true })
	end, "Procurar Arquivos (cwd)")
	fzf_map("<leader>fg", function()
		fzf.git_files()
	end, "Arquivos Git")
	fzf_map("<leader>fb", function()
		fzf.buffers({ sort_mru = true, sort_lastused = true })
	end, "Buffers")
	fzf_map("<leader>fr", function()
		fzf.oldfiles({ cwd = vim.uv.cwd() })
	end, "Arquivos Recentes (cwd)")
	fzf_map("<leader>fR", function()
		fzf.oldfiles()
	end, "Arquivos Recentes (global)")

	-- Grep
	fzf_map("<leader>/", function()
		fzf.live_grep()
	end, "Grep (Raiz)")
	fzf_map("<leader>sw", function()
		fzf.grep_cword()
	end, "Grep Palavra (Raiz)")
	fzf_map("<leader>sW", function()
		fzf.grep_cword({ cwd_only = true })
	end, "Grep Palavra (cwd)")
	fzf_map("<leader>sb", function()
		fzf.grep_curbuf()
	end, "Grep no Buffer Atual")
	fzf_map_v("<leader>sw", function()
		fzf.grep_visual()
	end, "Grep Seleção (Raiz)")
	fzf_map_v("<leader>sW", function()
		fzf.grep_visual({ cwd_only = true })
	end, "Grep Seleção (cwd)")

	-- Git
	fzf_map("<leader>gc", function()
		fzf.git_commits()
	end, "Commits")
	fzf_map("<leader>gs", function()
		fzf.git_status()
	end, "Git Status")

	-- LSP
	fzf_map("<leader>ss", function()
		fzf.lsp_document_symbols()
	end, "Símbolos do Documento")
	fzf_map("<leader>sS", function()
		fzf.lsp_workspace_symbols()
	end, "Símbolos do Workspace")

	-- Outros
	fzf_map("<leader>:", function()
		fzf.command_history()
	end, "Histórico de Comandos")
	fzf_map('<leader>s"', function()
		fzf.registers()
	end, "Registradores")
	fzf_map("<leader>sh", function()
		fzf.help_tags()
	end, "Help Tags")
	fzf_map("<leader>sk", function()
		fzf.keymaps()
	end, "Mapeamentos de Teclas")
	fzf_map("<leader>sM", function()
		fzf.man_pages()
	end, "Man Pages")
	fzf_map("<leader>sR", function()
		fzf.resume()
	end, "Resumir Última Busca")
end)
