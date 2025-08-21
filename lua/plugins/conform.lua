local now, later = MiniDeps.now, MiniDeps.later

later(function()
    MiniDeps.add("stevearc/conform.nvim")
    require("conform").setup({
        formatters_by_ft = {
            lua = { "stylua" },
        },
    })
end)
