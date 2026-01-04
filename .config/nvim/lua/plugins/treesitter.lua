return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = "main",
	opts = {
		ensure_installed = { "lua", "python" },
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
		},
	},
}
