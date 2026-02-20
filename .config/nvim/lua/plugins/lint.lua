return {
	"mfussenegger/nvim-lint",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			go = { "golangcilint" },
			python = { "ruff" },
		}

		lint.linters.golangci_lint = {
			cmd = "golangci-lint",
			stdin = false,
			args = {
				"run",
				"--out-format",
				"json",
			},
			parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", { source = "golangci-lint" }),
		}

		local lint_group = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_group,
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
