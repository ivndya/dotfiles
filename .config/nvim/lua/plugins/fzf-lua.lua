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
		})
		local fzf = require("fzf-lua")

		vim.keymap.set("n", "<leader>f", fzf.files, { desc = "File Search" })
		vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Grep Search" })
		vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Help Search" })
		vim.keymap.set("n", "<leader>bf", fzf.buffers, { desc = "Buffer Find" })
		vim.keymap.set("n", "<leader>gf", fzf.git_status, { desc = "Git changed files" })
	end,
}
