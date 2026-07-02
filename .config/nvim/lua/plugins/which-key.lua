return {
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		mappings = vim.g.have_nerd_font,
		preset = "helix",
		show_help = false,
		spec = {
			{ "<leader>b", group = "Buffer..." },
			{ "<leader>c", group = "Code..." },
		},
	},
}
