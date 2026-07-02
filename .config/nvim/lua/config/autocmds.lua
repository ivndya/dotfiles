vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "lua", "go", "javascript", "javascriptreact", "typescript", "typescriptreact", "php" },
	callback = function()
		vim.treesitter.start()
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
	pattern = "*",
	command = "silent! update",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true }
		local fzf = require("fzf-lua")

		opts.desc = "Goto References"
		vim.keymap.set("n", "gr", fzf.lsp_references, opts)

		opts.desc = "Goto Definition"
		vim.keymap.set("n", "gd", fzf.lsp_definitions, opts)

		opts.desc = "Goto Declaration"
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Goto Type Definitions"
		vim.keymap.set("n", "gy", fzf.lsp_typedefs, opts)

		opts.desc = "Goto Implementations"
		vim.keymap.set("n", "gi", fzf.lsp_implementations, opts)

		opts.desc = "Code Action"
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

		opts.desc = "Hover documentation"
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	end,
})

local indent_augroup = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = indent_augroup,
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
})
