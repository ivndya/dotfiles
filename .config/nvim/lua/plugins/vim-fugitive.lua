return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git Status" })
		vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
		vim.keymap.set("n", "<leader>gd", "<cmd>Git difftool<CR>", { desc = "Git Diff" })
		vim.keymap.set("n", "<leader>gm", "<cmd>Git mergetool<CR>", { desc = "Git Merge" })
		vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit<CR>", { desc = "Git VDiff" })
	end,
}
