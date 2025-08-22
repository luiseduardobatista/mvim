local add, later = MiniDeps.add, MiniDeps.later

add({ source = "kdheepak/lazygit.nvim", depends = { "nvim-lua/plenary.nvim" } })

later(function()
	vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
end)
