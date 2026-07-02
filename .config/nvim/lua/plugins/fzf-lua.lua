return {
	"ibhagwan/fzf-lua",
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
			},
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
		vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live Grep Search" })
		vim.keymap.set("n", "<leader>s", fzf.grep, { desc = "Grep Search" })
		vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Help Search" })
		vim.keymap.set("n", "<leader>bf", fzf.buffers, { desc = "Buffer Find" })
		vim.keymap.set("n", "<leader>gf", fzf.git_status, { desc = "Git changed files" })

		fzf.register_ui_select()
	end,
}
