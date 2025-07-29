-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

local function load_plugins()
  local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
  local files = vim.fn.glob(plugin_dir .. '/*.lua', false, true)
  for _, file in ipairs(files) do
    local plugin_name = vim.fn.fnamemodify(file, ':t:r') -- Extrai o nome do arquivo sem extensão
    require('plugins.' .. plugin_name)
  end
end

require 'options'
require 'keymaps'
load_plugins()
