--!strict
--[[
	Strings — textos del juego en español e inglés (decisión B7).
	Los textos viven en src/shared/Localization/Strings.csv (columnas Key, Source, Context, Example, es, en).
	Rojo convierte ese CSV en una LocalizationTable de Roblox; este módulo la lee al arrancar.
	El código NUNCA escribe textos visibles directamente: siempre usa Strings.get("Clave").

	Idioma: el de tu cuenta de Roblox, salvo que elijas otro en Ajustes (Strings.setLanguage).
	[VERIFICAR EN DOCUMENTACIÓN: "LocalizationTable:GetEntries"]
]]

local LocalizationService = game:GetService("LocalizationService")

local SUPPORTED = { "es", "en" }

local Strings = {}

local texts: { [string]: { [string]: string } } = { es = {}, en = {} }
local override: string? = nil -- "es", "en" o nil (automático)

local function load()
	local localizationFolder = script.Parent.Parent:WaitForChild("Localization", 10)
	local tableInstance = localizationFolder and localizationFolder:WaitForChild("Strings", 10)
	if not tableInstance or not tableInstance:IsA("LocalizationTable") then
		warn("[Strings] No se encontró la LocalizationTable 'Strings'")
		return
	end
	for _, entry in tableInstance:GetEntries() do
		local key = entry.Key
		local values = entry.Values
		if typeof(key) == "string" and typeof(values) == "table" then
			for _, language in SUPPORTED do
				local value = values[language]
				if typeof(value) == "string" and value ~= "" then
					texts[language][key] = value
				end
			end
		end
	end
end

local function robloxLanguage(): string
	local ok, locale = pcall(function()
		return LocalizationService.RobloxLocaleId
	end)
	if ok and typeof(locale) == "string" and string.sub(locale, 1, 2) == "es" then
		return "es"
	end
	return "en"
end

-- Idioma que se está usando ahora mismo ("es" o "en").
function Strings.currentLanguage(): string
	return override or robloxLanguage()
end

-- Cambia el idioma: "es", "en" o "auto" (el de la cuenta de Roblox).
function Strings.setLanguage(language: string)
	override = if table.find(SUPPORTED, language) then language else nil
end

-- Devuelve el texto de una clave, sustituyendo {param} por su valor.
function Strings.get(key: string, params: { [string]: any }?): string
	local language = Strings.currentLanguage()
	local text = texts[language][key] or texts.en[key] or key
	if params then
		text = string.gsub(text, "{(%w+)}", function(name: string)
			local value = params[name]
			return if value ~= nil then tostring(value) else `\{{name}\}`
		end)
	end
	return text
end

load()

return Strings
