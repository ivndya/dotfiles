return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({

			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
            current_line_blame = true,
			current_line_blame_opts = {
				delay = 0,
			},
		})

		vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", {})
		vim.keymap.set("n", "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<CR>", {})
		vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", {})
		vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", {})
	end,
}
