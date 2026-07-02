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
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "ruff" },
			php = { "php" },
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

		-- Линтеры, которых нет в системе, молча пропускаем: php и golangci-lint
		-- локально не стоят (проекты живут в докере), а try_lint() без проверки
		-- сыплет «Error running php: ENOENT» на каждом входе в буфер.
		local function available_linters()
			local result = {}
			for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
				local linter = lint.linters[name]
				local cmd = type(linter) == "table" and linter.cmd or name
				if type(cmd) == "function" then
					cmd = cmd()
				end
				if vim.fn.executable(cmd) == 1 then
					result[#result + 1] = name
				end
			end
			return result
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_group,
			callback = function()
				local linters = available_linters()
				if #linters > 0 then
					lint.try_lint(linters)
				end
			end,
		})
	end,
}
