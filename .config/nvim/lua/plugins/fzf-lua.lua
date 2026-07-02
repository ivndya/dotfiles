return {
	"ibhagwan/fzf-lua",
	-- VeryLazy, а не keys: маппинги должны создаваться обычным vim.keymap.set,
	-- иначе langmapper (он оборачивает именно его) не сделает русские дубли.
	-- Заодно register_ui_select() успевает отработать до первого vim.ui.select.
	event = "VeryLazy",
	config = function()
		require("fzf-lua").setup({
			lsp = {
				includeDeclaration = false,
			},
			defaults = {
				git_icons = false,
				file_icons = false,
				color_icons = false,
			},
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
			files = {
				fzf_opts = {
					["--exact"] = "",
				},
				-- .gitignore уважаем: он в каждом проекте свой и точнее любого
				-- нашего списка. С no_ignore в выдачу лезли .playwright-mcp,
				-- data/refs_cache, .pytest_cache, gradio_tmp — 463 файла вместо 392.
				-- Искать вместе с игнорируемым — <leader>F, симметрично <leader>?.
				hidden = true,
				-- Исключения дублируем в fd, а не в file_ignore_patterns: тот
				-- фильтрует уже в Lua, построчно (make_entry.lua), то есть fd сперва
				-- обойдёт весь .venv и отдаст все пути внутрь nvim. Нужны они
				-- в режиме <leader>F, где .gitignore отключён: без них там
				-- 38 192 файла, из которых 37 530 — .venv/lib.
				fd_opts = table.concat({
					"--color=never --type f --type l",
					"--exclude .git --exclude .jj",
					"--exclude .venv --exclude venv --exclude __pycache__",
					"--exclude node_modules --exclude vendor",
					"--exclude dist --exclude build --exclude target --exclude .next",
					"--exclude var/cache --exclude var/log --exclude public/bundles",
				}, " "),
			},
			-- Страховка для остальных провайдеров (grep, oldfiles, lsp): fd_opts
			-- выше действует только на files.
			file_ignore_patterns = {
				"node_modules/",
				"venv",
				".venv",
				"dist/",
				".next/",
				".git/",
				".gitlab/",
				"build/",
				"target/",
				"package-lock.json",
				"pnpm-lock.yaml",
				"yarn.lock",
				"uv.lock",
				"__pycache__",
				-- PHP / Symfony
				"vendor/",
				"var/cache/",
				"var/log/",
				"var/php/log/",
				"var/sessions/",
				"public/bundles/",
				"composer.lock",
				".phpunit.result.cache",
				".phpcs.cache",
				".php%-cs%-fixer.cache",
				".phpstan.cache/",
			},
		})

		local fzf = require("fzf-lua")

		vim.keymap.set("n", "<leader>f", fzf.files, { desc = "File Search" })
		vim.keymap.set("n", "<leader>F", function()
			fzf.files({ no_ignore = true })
		end, { desc = "File Search (incl. gitignored)" })
		vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live Grep Search" })
		vim.keymap.set("n", "<leader>?", function()
			fzf.live_grep({ rg_opts = "--no-ignore --hidden --column --line-number --no-heading --color=always --smart-case" })
		end, { desc = "Live Grep (incl. gitignored)" })
		vim.keymap.set("n", "<leader>s", fzf.grep, { desc = "Grep Search" })
		vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Help Search" })
		vim.keymap.set("n", "<leader>bf", fzf.buffers, { desc = "Buffer Find" })
		vim.keymap.set("n", "<leader>gf", fzf.git_status, { desc = "Git changed files" })

		fzf.register_ui_select()
	end,
}
