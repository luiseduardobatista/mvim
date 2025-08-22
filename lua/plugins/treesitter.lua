-- treesitter.lua
local add, later = MiniDeps.add, MiniDeps.later

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_install = function(params)
				vim.schedule(function()
					vim.cmd("TSUpdate")
				end)
			end,
			post_checkout = function(params)
				vim.schedule(function()
					vim.cmd("TSUpdate")
				end)
			end,
		},
	})

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"elixir",
			"heex",
			"javascript",
			"html",
			"markdown",
			"markdown_inline",
			"ninja",
			"rst",
			"rust",
			"ron",
		},
		auto_install = true,
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<Enter>",
				node_incremental = "<Enter>",
				scope_incremental = false,
				node_decremental = "<Backspace>",
			},
		},
	})
end)
