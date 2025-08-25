local add, later = MiniDeps.add, MiniDeps.later

add("stevearc/conform.nvim")
later(function()
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Desativa "format_on_save lsp_fallback" para linguagens que não
			-- têm um estilo de codificação bem padronizado.
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_format = "fallback" })
	end, { desc = "[C]ode [F]ormat buffer" })
end)

-- vim: ts=2 sts=2 sw=2 et
