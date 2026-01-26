vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true }
		local fzf_lua = require("fzf-lua")

		opts.desc = "Goto References"
		vim.keymap.set("n", "gr", fzf_lua.lsp_references, opts)

		opts.desc = "Goto Definition"
		vim.keymap.set("n", "gd", fzf_lua.lsp_definitions, opts)

		opts.desc = "Goto Type Definitions"
		vim.keymap.set("n", "gy", fzf_lua.lsp_type_definitions, opts)

		opts.desc = "Goto Implementations"
		vim.keymap.set("n", "gi", fzf_lua.lsp_implementations, opts)

		opts.desc = "Code Action"
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "lua" },
	callback = function()
		vim.treesitter.start()
	end,
})
