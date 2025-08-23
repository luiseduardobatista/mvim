local add, later = MiniDeps.add, MiniDeps.later
add({ source = "mrcjkb/rustaceanvim", checkout = "master" })
add({ source = "Saecki/crates.nvim" })

later(function()
	require("crates").setup({
		completion = {
			crates = { enabled = true },
		},
		lsp = {
			enabled = true,
			actions = true,
			completion = true,
			hover = true,
		},
	})

	vim.g.rustaceanvim = {
		server = {
			on_attach = function(_, bufnr)
				vim.keymap.set("n", "<leader>cR", function()
					vim.cmd.RustLsp("codeAction")
				end, { desc = "Rust Code Action", buffer = bufnr })

				vim.keymap.set("n", "<leader>dr", function()
					vim.cmd.RustLsp("debuggables")
				end, { desc = "Rust Debuggables", buffer = bufnr })
			end,
			default_settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = true,
					check = {
						command = "clippy",
					},
					diagnostics = {
						enable = true,
					},
					procMacro = {
						enable = true,
						ignored = {
							["async-trait"] = { "async_trait" },
							["napi-derive"] = { "napi" },
							["async-recursion"] = { "async_recursion" },
						},
					},
					files = {
						excludeDirs = {
							".direnv",
							".git",
							".github",
							".gitlab",
							"bin",
							"node_modules",
							"target",
							"venv",
							".venv",
						},
					},
				},
			},
		},
	}
end)
