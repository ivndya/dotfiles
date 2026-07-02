-- Дублирует все маппинги (свои и плагинов) для русской раскладки.
-- hack_keymap=true (дефолт) оборачивает vim.keymap.set — маппинги, созданные
-- после загрузки (remap.lua, lsp.lua, lazy-loaded плагины), переводятся сами.
-- Плагины, загруженные раньше него, добирает automapping() в конце init.lua.
return {
	"Wansmer/langmapper.nvim",
	lazy = false,
	priority = 1,
	config = function()
		require("langmapper").setup({})
	end,
}
