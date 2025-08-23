local add, later = MiniDeps.add, MiniDeps.later

add({
	source = "ray-x/go.nvim",
	depends = {
		"ray-x/guihua.lua", -- Opcional, mas recomendado para floating windows
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
})

later(function()
	require("go").setup({
		lsp_cfg = true,
		lsp_keymaps = false,
		test_runner = "gotestsum",
	})

	local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*.go",
		callback = function()
			require("go.format").goimports()
		end,
		group = format_sync_grp,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "go",
		callback = function()
			local parsers = require("nvim-treesitter.parsers")
			if not parsers.has_parser("go") then
				vim.cmd("TSInstall go")
			end
		end,
		once = true,
	})
end)
