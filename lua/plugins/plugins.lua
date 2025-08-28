local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add("stevearc/conform.nvim")
later(function()
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Desativa "format_on_save lsp_fallback" para linguagens que não
			-- têm um estilo de codificação bem padronizado.
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "golines", "gofumpt" },
			python = { "ruff_format", "ruff_organize_imports" },

			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_format = "fallback" })
	end, { desc = "[C]ode [F]ormat buffer" })
end)

later(function()
	add("folke/flash.nvim")
	require("flash").setup({})

	local flash = require("flash")

	vim.keymap.set({ "n", "x" }, "s", "<Nop>", { noremap = true, silent = true })

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		flash.jump()
	end, { desc = "Flash: Jump" })
	vim.keymap.set({ "n", "o", "x" }, "S", function()
		flash.treesitter()
	end, { desc = "Flash: Treesitter" })
	vim.keymap.set("o", "r", function()
		flash.remote()
	end, { desc = "Flash: Remote" })
	vim.keymap.set({ "o", "x" }, "R", function()
		flash.treesitter_search()
	end, { desc = "Flash: Treesitter Search" })
	vim.keymap.set("c", "<c-s>", function()
		flash.toggle()
	end, { desc = "Flash: Toggle Search" })
end)

later(function()
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
	local actions = fzf.actions

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
			actions = {
				["alt-i"] = { actions.toggle_ignore },
				["alt-h"] = { actions.toggle_hidden },
			},
			cwd_prompt = false,
		},
		grep = {
			actions = {
				["alt-i"] = { actions.toggle_ignore },
				["alt-h"] = { actions.toggle_hidden },
			},
		},
		oldfiles = {
			include_current_session = true,
		},
		lsp = {
			symbols = {
				child_prefix = false,
			},
			code_actions = {
				previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
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
	fzf_map("<leader>sg", function()
		fzf.live_grep()
	end, "Live Grep (Root dir)")
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
	end, "Live Grep (cwd)")

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

-- LuaSnip (Snippet Engine)
add({
	source = "L3MON4D3/LuaSnip",
	hooks = {
		post_install = function()
			-- Build Step is needed for regex support in snippets.
			-- This step is not supported in many windows environments.
			if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				return
			end
			vim.fn.system("make install_jsregexp")
		end,
	},
})

now(function()
	add({
		source = "saghen/blink.cmp",
		checkout = "v1.6.0",
		depends = { "folke/lazydev.nvim" },
	})
	require("luasnip").setup({})
	require("blink.cmp").setup({
		keymap = {
			preset = "enter",
			["<C-y>"] = { "select_and_accept" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "lazydev" },
			providers = {
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
	})
end)

later(function()
	-- Monkeypatch in a PR to remove a call to the deprecated `client.notify`
	-- function.
	--
	-- See: https://github.com/folke/lazydev.nvim/pull/106
	local config = require("lazydev.config")
	config.have_0_11 = vim.fn.has("nvim-0.11") == 1

	local lsp = require("lazydev.lsp")
	lsp.update = function(client)
		lsp.assert(client)
		if config.have_0_11 then
			client:notify("workspace/didChangeConfiguration", {
				settings = { Lua = {} },
			})
		else
			client.notify("workspace/didChangeConfiguration", {
				settings = { Lua = {} },
			})
		end
	end

	require("lazydev").setup({
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})
end)

later(function()
	add("christoomey/vim-tmux-navigator")
	local map = vim.keymap.set
	if vim.env.TMUX then
		map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
		map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down" })
		map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up" })
		map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right" })
		map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Navigate previous" })
	else
		map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
		map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
		map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
		map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	end
end)

later(function()
	add({ source = "kdheepak/lazygit.nvim", depends = { "nvim-lua/plenary.nvim" } })
	vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
end)

add({
	source = "linux-cultist/venv-selector.nvim",
	checkout = "main",
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

-- now(function()
-- 	add("stevearc/oil.nvim")
-- 	require("oil").setup({
-- 		options = {
-- 			default_file_explorer = true,
-- 			view_options = {
-- 				show_hidden = true,
-- 				is_always_hidden = function(name, _)
-- 					local always_hidden = {
-- 						[".git"] = true,
-- 						[".idea"] = true,
-- 						[".gitlab"] = true,
-- 						[".."] = true,
-- 					}
-- 					if always_hidden[name] then
-- 						return true
-- 					end
-- 					return name:match("._cache/?$") ~= nil
-- 				end,
-- 			},
-- 		},
-- 	})
-- 	vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- end)
--
--
-- add({
-- 	source = "folke/trouble.nvim",
-- })
--
-- later(function()
-- 	require("trouble").setup({})
-- 	vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
-- 	vim.keymap.set(
-- 		"n",
-- 		"<leader>xX",
-- 		"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
-- 		{ desc = "Buffer Diagnostics (Trouble)" }
-- 	)
-- 	vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
-- 	vim.keymap.set(
-- 		"n",
-- 		"<leader>cl",
-- 		"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
-- 		{ desc = "LSP Definitions / references / ... (Trouble)" }
-- 	)
-- 	vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
-- 	vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
-- end)
