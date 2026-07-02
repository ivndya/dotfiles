-- Сами серверы включаются вручную в lua/config/lsp.lua, здесь только гарантия,
-- что бинарники установлены: без этого vim.lsp.enable() молча ничего не делает.
return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "pyright", "ruff", "lua_ls", "intelephense" },
			automatic_enable = false,
		},
	},
}
