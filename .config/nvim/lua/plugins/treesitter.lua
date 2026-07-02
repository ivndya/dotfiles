-- Ветка main — переписанный плагин с другим API: ensure_installed / auto_install /
-- highlight из старой master-ветки здесь молча игнорируются. Парсеры ставятся
-- вызовом install(), подсветку включает vim.treesitter.start() в autocmds.lua.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"lua",
			"python",
			"go",
			"typescript",
			"tsx",
			"javascript",
			"php",
			"markdown",
			"markdown_inline",
			"json",
			"yaml",
			"toml",
			"sql",
			"bash",
			"dockerfile",
		})
	end,
}
