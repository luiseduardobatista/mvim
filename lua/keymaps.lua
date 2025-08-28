-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local function diagnostics_to_quickfix()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end

local function buffer_diagnostics_to_loclist()
	vim.diagnostic.setloclist()
	vim.cmd("lopen")
end

local function lsp_references_to_quickfix()
	vim.lsp.buf.references(nil, {
		on_list = function(options)
			vim.fn.setqflist({}, " ", options)
			vim.cmd("copen")
		end,
	})
end

local function toggle_quickfix()
	local windows = vim.fn.getwininfo()
	for _, win in pairs(windows) do
		if win.quickfix == 1 then
			vim.cmd("cclose")
			return
		end
	end
	vim.cmd("copen")
end

local function toggle_loclist()
	local windows = vim.fn.getwininfo()
	for _, win in pairs(windows) do
		if win.loclist == 1 then
			vim.cmd("lclose")
			return
		end
	end
	vim.cmd("lopen")
end

-- Diagnostics and Quickfix/Loclist keymaps
vim.keymap.set("n", "<leader>xx", diagnostics_to_quickfix, { desc = "Diagnostics (Quickfix)" })
vim.keymap.set("n", "<leader>xX", buffer_diagnostics_to_loclist, { desc = "Buffer Diagnostics (Location List)" })
vim.keymap.set("n", "<leader>cl", lsp_references_to_quickfix, { desc = "LSP References (Quickfix)" })
vim.keymap.set("n", "<leader>xL", toggle_loclist, { desc = "Toggle Location List" })
vim.keymap.set("n", "<leader>xQ", toggle_quickfix, { desc = "Toggle Quickfix List" })

-- Diagnostics navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>xf", function()
	vim.diagnostic.open_float(nil, {
		scope = "buffer",
		header = "Diagnostics",
		border = "rounded",
	})
end, { desc = "Floating Diagnostics" })

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-on-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- vim: ts=2 sts=2 sw=2 et
