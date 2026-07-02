require("config.lazy")
require("config.remap")
require("config.lsp")

-- Должно быть последним: дублирует уже существующие маппинги для русской раскладки
require("langmapper").automapping({ global = true, buffer = true })
