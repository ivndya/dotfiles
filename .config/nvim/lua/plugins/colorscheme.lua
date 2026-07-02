-- Обе темы стоят всегда, применяется активная (~/.config/theme/current):
--   ubuntu  — base16-nvim с палитрой GNOME Terminal из Ubuntu
--   dracula — Mofiqul/dracula.nvim
-- Переключение: `theme ubuntu|dracula` в шелле (заодно перекрасит alacritty,
-- tmux и fzf) либо :Theme <имя> внутри nvim. Логика — в lua/config/theme.lua.
return {
	{
		"RRethy/base16-nvim",
		lazy = false,
		priority = 1000,
		-- dracula.nvim в зависимостях, а не отдельным спеком: lazy.nvim грузит
		-- зависимости раньше, поэтому colorscheme dracula доступна к моменту apply().
		dependencies = { "Mofiqul/dracula.nvim" },
		config = function()
			require("config.theme").setup()
		end,
	},
}
