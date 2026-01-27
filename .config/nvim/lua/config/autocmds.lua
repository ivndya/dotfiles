vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "lua" },
	callback = function()
		vim.treesitter.start()
	end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	pattern = "*",
	command = "silent! update",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.py", "*.lua" },
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local ft = vim.bo[ev.buf].filetype
		if ft ~= "python" and ft ~= "lua" then
			return
		end

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

local augroup = vim.api.nvim_create_augroup("PyLuaIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "python", "lua" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true
	end,
})
