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

require("mason").setup({})
-- require("fidget").setup({})

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
			map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
			map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")
			map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", require("fzf-lua").lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")
			map("<leader>cr", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", require("fzf-lua").lsp_code_actions, "[C]ode [A]ction", { "n", "x" })
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
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

			if
				client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
			then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

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

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	local servers = {
		bashls = {},
		marksman = {},
		lua_ls = {},
		basedpyright = {},
		rust_analyzer = { enabled = false },
		ruff = {
			init_options = {
				settings = {
					logLevel = "error",
				},
			},
			on_attach = function(client, bufnr)
				client.server_capabilities.hoverProvider = false
			end,
		},
	}

	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		"stylua",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	require("mason-lspconfig").setup({
		ensure_installed = {}, -- We let mason-tool-installer handle this
		automatic_installation = false,
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end)
