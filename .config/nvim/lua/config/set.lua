vim.o.nu = true
vim.o.rnu = true
vim.o.clipboard = ""
vim.o.winborder = "rounded"

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.opt.listchars = { tab = "  " }
vim.o.list = true
-- vim.opt.guicursor = "n-v-c-i:block"

vim.o.smartindent = true
vim.o.showmode = false
vim.g.have_nerd_font = true
vim.o.cursorline = true

vim.o.signcolumn = "yes"

vim.o.wrap = false

vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.incsearch = true

vim.o.termguicolors = true

vim.o.scrolloff = 8

vim.o.updatetime = 50
vim.opt.hidden = false

vim.o.splitright = true
vim.opt.wrap = true

require("config.autocmds")

pcall(vim.keymap.del, { "x", "n" }, "gra")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "grt")

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})
