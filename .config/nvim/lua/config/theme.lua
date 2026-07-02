-- Общая тема для терминала: alacritty + tmux + nvim + fzf переключаются одной
-- командой `theme ubuntu|dracula` (скрипт ~/.local/bin/theme).
--
-- Имя активной темы лежит в ~/.config/theme/current, сама тема — в
-- ~/.config/theme/themes/<имя>/nvim.lua (файл возвращает функцию-применялку).
-- Уже открытым nvim скрипт шлёт SIGUSR1 — тема меняется без перезапуска.

local M = {}

local root = vim.fn.expand("~/.config/theme")
local fallback = "ubuntu"

local function current()
	local fd = io.open(root .. "/current", "r")
	if not fd then
		return fallback
	end
	local name = vim.trim(fd:read("l") or "")
	fd:close()
	return name ~= "" and name or fallback
end

function M.apply(name)
	name = name or current()
	local path = root .. "/themes/" .. name .. "/nvim.lua"
	local chunk, err = loadfile(path)
	if not chunk then
		-- Система тем нужна там, где есть что перекрашивать помимо nvim
		-- (alacritty + tmux). Где её нет или где она развёрнута наполовину
		-- (на маке в теме лежал только tmux.conf) — просто dracula, в тон
		-- встроенной теме ghostty. Ругаемся лишь на битый файл темы, который
		-- есть на диске, но не читается.
		if not vim.uv.fs_stat(path) then
			pcall(vim.cmd.colorscheme, "dracula")
			return
		end
		vim.notify("theme: не читается " .. path .. ": " .. err, vim.log.levels.ERROR)
		return
	end
	local ok, result = pcall(chunk)
	if ok then
		ok, result = pcall(result)
	end
	if not ok then
		vim.notify("theme: " .. name .. " не применилась: " .. tostring(result), vim.log.levels.ERROR)
	end
end

function M.setup()
	M.apply()

	-- Скрипт `theme` шлёт SIGUSR1 всем nvim: перекрашиваемся на лету.
	vim.api.nvim_create_autocmd("Signal", {
		pattern = "SIGUSR1",
		group = vim.api.nvim_create_augroup("theme_switch", { clear = true }),
		callback = function()
			M.apply()
		end,
	})

	-- Ручное переключение изнутри nvim: :Theme dracula (без аргумента — перечитать
	-- активную). Меняет тему только в этом nvim; общесистемно — команда `theme`.
	vim.api.nvim_create_user_command("Theme", function(opts)
		M.apply(opts.args ~= "" and opts.args or nil)
	end, {
		nargs = "?",
		complete = function()
			local ok, names = pcall(vim.fn.readdir, root .. "/themes")
			return ok and names or {}
		end,
	})
end

return M
