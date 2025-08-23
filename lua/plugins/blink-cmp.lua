local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

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

add({
	source = "saghen/blink.cmp",
	checkout = "v1.6.0",
	depends = { "folke/lazydev.nvim" },
})

now(function()
	-- Configure LuaSnip
	require("luasnip").setup({})

	-- Configure Blink.cmp
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
