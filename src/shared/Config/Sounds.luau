--!strict
--[[
	Sonidos del juego. Cada clave es un momento del juego; el valor es el ID del sonido.
	- "rbxasset://sounds/..." son sonidos que vienen incluidos con Roblox (provisionales). [VERIFICAR EN STUDIO]
	- "rbxassetid://123..." son sonidos del Creator Store (Studio: Window → Toolbox → Audio; usa los gratuitos).
	- "" = sin sonido (no pasa nada si falta).
	Todos suenan a través del grupo "Effects", así que respetan el volumen de Ajustes.
]]

local Sounds = {
	-- Combate
	Swing = "rbxasset://sounds/swordslash.wav",
	HeavySwing = "rbxasset://sounds/swordlunge.wav",
	Hit = "",
	CritHit = "",
	Block = "",
	PerfectBlock = "",
	Dodge = "",
	Hurt = "",
	Telegraph = "",
	EnemyDeath = "",
	-- Habilidades
	AbilityFire = "",
	AbilityLightning = "",
	Resonance = "",
	-- Jefe
	BossRoar = "",
	-- Progresión y mundo
	LevelUp = "",
	Potion = "",
	Equip = "rbxasset://sounds/unsheath.wav",
	QuestComplete = "rbxasset://sounds/electronicpingshort.wav",
	FragmentFound = "",
	Campfire = "",
}

return table.freeze(Sounds)
