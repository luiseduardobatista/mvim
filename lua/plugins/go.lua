local add, later = MiniDeps.add, MiniDeps.later

-- add({
-- 	source = "ray-x/go.nvim",
-- 	depends = {
-- 		"ray-x/guihua.lua", -- Opcional, mas recomendado para floating windows
-- 		"neovim/nvim-lspconfig",
-- 		"nvim-treesitter/nvim-treesitter",
-- 	},
-- })
--
-- later(function()
-- 	require("go").setup({
-- 		lsp_cfg = false,
-- 		lsp_keymaps = false,
-- 		verbose = false,
-- 		test_runner = "gotestsum",
-- 		-- max_line_len = 120,
-- 	})
--
-- 	local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
-- 	vim.api.nvim_create_autocmd("BufWritePre", {
-- 		pattern = "*.go",
-- 		callback = function()
-- 			require("go.format").goimports()
-- 		end,
-- 		group = format_sync_grp,
-- 	})
--
-- 	vim.api.nvim_create_autocmd("FileType", {
-- 		pattern = "go",
-- 		callback = function()
-- 			local parsers = require("nvim-treesitter.parsers")
-- 			if not parsers.has_parser("go") then
-- 				vim.cmd("TSInstall go")
-- 			end
-- 		end,
-- 		once = true,
-- 	})
-- end)
--
add({
	source = "olexsmir/gopher.nvim",
})

later(function()
	local gopher_loaded = false
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "go",
		callback = function()
			if not gopher_loaded then
				require("gopher").setup({
					commands = {
						gotests = "gotestsum",
					},
				})
				gopher_loaded = true
			end
		end,
	})
end)
