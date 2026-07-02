return {
	"stevearc/conform.nvim",
	dependencies = {
		"mason-org/mason.nvim",
		"zapling/mason-conform.nvim",
	},
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },

				-- ruff вместо black+isort: тот же бинарь, что и LSP, ставится без
				-- Python (системный на macOS — 3.9, а black требует ≥3.10)
				python = { "ruff_organize_imports", "ruff_format" },

				go = {
					"goimports",
					"gofumpt",
				},

				php = { "php_cs_fixer", stop_after_first = true },

				javascript = { "eslint_d", "prettierd" },
				javascriptreact = { "eslint_d", "prettierd" },
				typescript = { "eslint_d", "prettierd" },
				typescriptreact = { "eslint_d", "prettierd" },
				json = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
			},
		})

		require("mason-conform").setup({
			-- Go на этой машине нет, ставить нечем: mason собирает эти два из
			-- исходников через `go install`. Появится Go — :MasonInstall goimports gofumpt
			ignore_install = { "goimports", "gofumpt", "ruff_organize_imports", "ruff_format" },
		})
	end,
}
