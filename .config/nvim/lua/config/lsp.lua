vim.lsp.enable({ "pyright", "ruff" })
vim.lsp.enable({ "lua_ls" })
vim.lsp.enable({ "ts_ls", "emmet_ls" })

vim.lsp.config("gopls", {
	settings = {
		["gopls"] = { gofumpt = true },
	},
})
vim.lsp.enable({ "gopls" })

vim.lsp.enable({ "intelephense" })
