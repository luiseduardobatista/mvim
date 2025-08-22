-- Unset conflicting keymaps from other default neovim lsp settings
-- pcall is used to avoid errors if the keymaps do not exist.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		pcall(vim.keymap.del, "n", "grr")
		pcall(vim.keymap.del, "n", "gra")
		pcall(vim.keymap.del, "n", "grn")
		pcall(vim.keymap.del, "n", "gri")
		pcall(vim.keymap.del, "n", "grt")
		pcall(vim.keymap.del, "x", "gra")
	end,
})

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add("neovim/nvim-lspconfig")
add("mason-org/mason.nvim")
add("mason-org/mason-lspconfig.nvim")
add("WhoIsSethDaniel/mason-tool-installer.nvim")
add("j-hui/fidget.nvim")

-- 2. Configure the plugins
-- The order here is important. Mason must be configured before plugins that depend on it.
require("mason").setup({})
require("fidget").setup({})

later(function()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
			end

			map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
			map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")

			-- Jump to the implementation of the word under your cursor.
			--  Useful when your language has ways of declaring types without an actual implementation.
			map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")

			map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")

			-- Fuzzy find all the symbols in your current document.
			--  Symbols are things like variables, functions, types, etc.
			map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")

			-- Fuzzy find all the symbols in your current workspace.
			--  Similar to document symbols, except searches over your entire project.
			map("<leader>ws", require("fzf-lua").lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")

			map("<leader>cr", vim.lsp.buf.rename, "[R]e[n]ame")

			map("<leader>ca", require("fzf-lua").lsp_code_actions, "[C]ode [A]ction", { "n", "x" })

			-- WARN: This is not Goto Definition, this is Goto Declaration.
			--  For example, in C this would take you to the header.
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
			local function client_supports_method(client, method, bufnr)
				if vim.fn.has("nvim-0.11") == 1 then
					return client:supports_method(method, bufnr)
				else
					return client.supports_method(method, { bufnr = bufnr })
				end
			end

			-- The following two autocommands are used to highlight references of the
			-- word under your cursor when your cursor rests there for a little while.
			--    See `:help CursorHold` for information about when this is executed
			--
			-- When you move your cursor, the highlights will be cleared (the second autocommand).
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if
				client
				and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
			then
				local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})

				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					callback = function(event2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
					end,
				})
			end

			-- The following code creates a keymap to toggle inlay hints in your
			-- code, if the language server you are using supports them
			--
			-- This may be unwanted, since they displace some of your code
			if
				client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
			then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	-- Diagnostic Config - See :help vim.diagnostic.config
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = vim.diagnostic.severity.ERROR },
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
		},
		virtual_text = {
			source = "if_many",
			spacing = 2,
			format = function(diagnostic)
				local diagnostic_message = {
					[vim.diagnostic.severity.ERROR] = diagnostic.message,
					[vim.diagnostic.severity.WARN] = diagnostic.message,
					[vim.diagnostic.severity.INFO] = diagnostic.message,
					[vim.diagnostic.severity.HINT] = diagnostic.message,
				}
				return diagnostic_message[diagnostic.severity]
			end,
		},
	})

	-- LSP servers and clients are able to communicate to each other what features they support.
	--  By default, Neovim doesn't support everything that is in the LSP specification.
	--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
	--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

	-- Enable the following language servers
	--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
	--
	--  Add any additional override configuration in the following tables. Available keys are:
	--  - cmd (table): Override the default command used to start the server
	--  - filetypes (table): Override the default list of associated filetypes for the server
	--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
	--  - settings (table): Override the default settings passed when initializing the server.
	--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
	local servers = {
		bashls = {},
		marksman = {},
		lua_ls = {},
		basedpyright = {},
		ruff = {
			init_options = {
				settings = {
					logLevel = "error",
				},
			},
			on_attach = function(client, bufnr)
				-- Desativa o hover do ruff para dar preferência ao basedpyright
				client.server_capabilities.hoverProvider = false
			end,
		},
	}

	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		"stylua", -- Used to format Lua code
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	-- Configure mason-lspconfig to use the servers from the list
	require("mason-lspconfig").setup({
		ensure_installed = {}, -- We let mason-tool-installer handle this
		automatic_installation = false,
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				-- This handles overriding only values explicitly passed
				-- by the server configuration above. Useful when disabling
				-- certain features of an LSP.
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end)
