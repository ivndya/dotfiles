return {
	"stevearc/conform.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"zapling/mason-conform.nvim",
	},
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },

				python = { "isort", "black" },

				go = {
					"goimports",
					"gofumpt",
				},
			},
		})

		require("mason-conform").setup({})
	end,
}
