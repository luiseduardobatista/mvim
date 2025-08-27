local add, later = MiniDeps.add, MiniDeps.later
add("christoomey/vim-tmux-navigator")

later(function()
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
