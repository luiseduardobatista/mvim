local now, later = MiniDeps.now, MiniDeps.later

now(
    function()
        MiniDeps.add("stevearc/oil.nvim")
        require("oil").setup(
            {
                options = {
                    default_file_explorer = true,
                    view_options = {
                        show_hidden = true,
                        is_always_hidden = function(name, _)
                            local always_hidden = {
                                [".git"] = true,
                                [".idea"] = true,
                                [".gitlab"] = true,
                                [".."] = true
                            }
                            if always_hidden[name] then
                                return true
                            end
                            return name:match("._cache/?$") ~= nil
                        end
                    }
                }
            }
        )
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", {desc = "Open parent directory"})
    end
)
