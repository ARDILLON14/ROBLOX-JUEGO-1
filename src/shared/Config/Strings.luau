--!strict
--[[
	Textos del juego en español e inglés.
	[PENDIENTE] Semana 19: pasar estos textos a archivos CSV / LocalizationTable (decisión B7).
	Mientras tanto, todos los textos visibles se piden aquí con una clave.
]]

local LocalizationService = game:GetService("LocalizationService")

local TEXTS: { [string]: { [string]: string } } = {
	es = {
		LevelUp = "¡NIVEL {level}!",
		RewardPotion = "+1 Poción",
		RewardHeal = "Vida restaurada",
		RewardAffinity = "¡Ya puedes despertar tu afinidad!",
		Title_DawnSeeker = "Nuevo título: Explorador del Alba",
		Aura_AetherEmber = "Nueva aura: Brasa de Éter",
		Title_VerdantiaGuardian = "Nuevo título: Guardián de Verdantia",
		DebugHud = "Nv {level} · XP {xp}/{next} · Pociones {potions}",
		DebugHudMax = "Nv {level} (máx.) · Pociones {potions}",
		Blocked = "Bloqueado {amount}",
		PerfectBlock = "¡Perfecto!",
		Enemy_Thornling = "Brotespina",
		EnemyName = "{name} · Nv {level}",
	},
	en = {
		LevelUp = "LEVEL {level}!",
		RewardPotion = "+1 Potion",
		RewardHeal = "Health restored",
		RewardAffinity = "You can now awaken your affinity!",
		Title_DawnSeeker = "New title: Dawn Seeker",
		Aura_AetherEmber = "New aura: Aether Ember",
		Title_VerdantiaGuardian = "New title: Guardian of Verdantia",
		DebugHud = "Lv {level} · XP {xp}/{next} · Potions {potions}",
		DebugHudMax = "Lv {level} (max) · Potions {potions}",
		Blocked = "Blocked {amount}",
		PerfectBlock = "Perfect!",
		Enemy_Thornling = "Thornling",
		EnemyName = "{name} · Lv {level}",
	},
}

local Strings = {}

local function currentLanguage(): string
	local ok, locale = pcall(function()
		return LocalizationService.RobloxLocaleId
	end)
	if ok and typeof(locale) == "string" and string.sub(locale, 1, 2) == "es" then
		return "es"
	end
	return "en"
end

-- Devuelve el texto de una clave, sustituyendo {param} por su valor.
function Strings.get(key: string, params: { [string]: any }?): string
	local language = currentLanguage()
	local text = TEXTS[language][key] or TEXTS.en[key] or key
	if params then
		text = string.gsub(text, "{(%w+)}", function(name: string)
			local value = params[name]
			return if value ~= nil then tostring(value) else `\{{name}\}`
		end)
	end
	return text
end

return Strings
