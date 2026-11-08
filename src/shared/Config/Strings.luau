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
		Blocked = "Bloqueado {amount}",
		PerfectBlock = "¡Perfecto!",
		Enemy_Thornling = "Brotespina",
		EnemyName = "{name} · Nv {level}",
		Npc_Ilen = "Maestra Ilen",
		Talk = "Hablar",
		Continue = "Continuar",
		Item_SapPotion = "Poción de Savia",
		Potions = "Pociones x{count}  [1]",
		DodgeReady = "Esquiva [Q]",
		DodgeCooldown = "Esquiva {time}",
		LevelShort = "Nv {level}",
		XPText = "{xp}/{next} XP",
		XPMax = "Nivel máximo",
		QuestTitle = "Misión",
		QuestTalkTo = "Habla con {npc}",
		QuestReturnTo = "Vuelve con {npc}",
		QuestNone = "Más misiones muy pronto…",
		QuestReady = "¡Objetivo cumplido! Vuelve con {npc}",
		QuestComplete = "Misión completada: {name}",
		Quest_Q01_Name = "Despertar del Explorador",
		Quest_Q01_Objective = "Golpea al muñeco de práctica ({progress}/{count})",
		Quest_Q02_Name = "Raíces Inquietas",
		Quest_Q02_Objective = "Derrota Brotespinas en la Linde Esmeralda ({progress}/{count})",
		Dialog_Q01_Start = "Bienvenido al Campamento del Alba, explorador. Antes de entrar al bosque, demuéstrame que sabes usar tu katana: golpea al muñeco de práctica. Clic izquierdo para atacar; clic derecho para un golpe pesado.",
		Dialog_Q01_Active = "Golpea al muñeco unas cuantas veces más. Prueba el combo: dos clics izquierdos y uno derecho.",
		Dialog_Q01_Done = "¡Bien hecho! Recuerda: Q para esquivar y F para bloquear. Si bloqueas justo antes del golpe, aturdirás al enemigo.",
		Dialog_Q02_Start = "El Éter corrompido ha despertado a las raíces del bosque. Sigue el camino hacia el norte hasta la Linde Esmeralda y derrota a los Brotespinas. Cuando brillen, ¡prepárate para bloquear o esquivar!",
		Dialog_Q02_Active = "Los Brotespinas siguen inquietos en la Linde Esmeralda, al norte. No vuelvas hasta calmar a unos cuantos.",
		Dialog_Q02_Done = "Has demostrado valor. El bosque guarda muchos secretos… Pronto tendré otra tarea para ti.",
		Dialog_NoQuest = "Descansa, explorador. Pronto habrá más por hacer.",
	},
	en = {
		LevelUp = "LEVEL {level}!",
		RewardPotion = "+1 Potion",
		RewardHeal = "Health restored",
		RewardAffinity = "You can now awaken your affinity!",
		Title_DawnSeeker = "New title: Dawn Seeker",
		Aura_AetherEmber = "New aura: Aether Ember",
		Title_VerdantiaGuardian = "New title: Guardian of Verdantia",
		Blocked = "Blocked {amount}",
		PerfectBlock = "Perfect!",
		Enemy_Thornling = "Thornling",
		EnemyName = "{name} · Lv {level}",
		Npc_Ilen = "Master Ilen",
		Talk = "Talk",
		Continue = "Continue",
		Item_SapPotion = "Sap Potion",
		Potions = "Potions x{count}  [1]",
		DodgeReady = "Dodge [Q]",
		DodgeCooldown = "Dodge {time}",
		LevelShort = "Lv {level}",
		XPText = "{xp}/{next} XP",
		XPMax = "Max level",
		QuestTitle = "Quest",
		QuestTalkTo = "Talk to {npc}",
		QuestReturnTo = "Return to {npc}",
		QuestNone = "More quests coming soon…",
		QuestReady = "Objective complete! Return to {npc}",
		QuestComplete = "Quest complete: {name}",
		Quest_Q01_Name = "Seeker's Awakening",
		Quest_Q01_Objective = "Hit the training dummy ({progress}/{count})",
		Quest_Q02_Name = "Restless Roots",
		Quest_Q02_Objective = "Defeat Thornlings in the Emerald Verge ({progress}/{count})",
		Dialog_Q01_Start = "Welcome to Dawn Camp, seeker. Before you enter the forest, show me you can use your katana: strike the training dummy. Left click to attack; right click for a heavy strike.",
		Dialog_Q01_Active = "Hit the dummy a few more times. Try the combo: two left clicks and one right click.",
		Dialog_Q01_Done = "Well done! Remember: Q to dodge and F to block. Block right before a hit to stun your enemy.",
		Dialog_Q02_Start = "Corrupted Aether has awakened the forest roots. Follow the path north to the Emerald Verge and defeat the Thornlings. When they glow, get ready to block or dodge!",
		Dialog_Q02_Active = "The Thornlings are still restless in the Emerald Verge, to the north. Don't come back until you've calmed a few.",
		Dialog_Q02_Done = "You have shown courage. The forest holds many secrets… I'll have another task for you soon.",
		Dialog_NoQuest = "Rest, seeker. There will be more to do soon.",
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
