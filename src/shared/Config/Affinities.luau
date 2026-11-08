--!strict
--[[
	Afinidades y maestría (GDD v1 §4.4 y §7.4, opción B aprobada).
	Rango 1: habilidad · Rango 2: mejora de la habilidad · Rango 3: ulti.
	Daños "base": se escalan con el nivel del jugador (+4 % por nivel). Valores iniciales, se ajustan en pruebas.
]]

export type AffinityConfig = {
	NameKey: string,
	SkillNameKey: string,
	UltimateNameKey: string,
	Color: Color3,
	SkillCooldown: number,
	SkillDamage: number,
	UltimateDamage: number,
	-- Fuego
	SkillRange: number?,
	SkillWidth: number?,
	SkillWidthRank2: number?,
	BurnDuration: number?,
	BurnDurationRank2: number?,
	BurnTickDamage: number?,
	UltimateRadius: number?,
	-- Rayo
	DashDistance: number?,
	DashWidth: number?,
	ChainCount: number?,
	ChainRange: number?,
	ChainDamageFraction: number?,
	UltimateDistance: number?,
}

local Affinities = {
	Ranks = { 0, 600, 2000 }, -- puntos de maestría para R1, R2, R3 (tabla ampliable)
	MasteryPerAbilityHit = 10,
	MasteryPerKill = 5,
	UltimateChargeDamage = 500, -- daño total para cargar la ulti (no se guarda al salir)
	CastTime = 0.35, -- tiempo ocupado al lanzar una habilidad
	RequiredLevel = 5,
	ShrineRange = 14, -- distancia máxima al Santuario para elegir afinidad

	ResonanceDamage = 30,
	ResonanceRadius = 8,

	List = {
		Fire = {
			NameKey = "Affinity_Fire",
			SkillNameKey = "Skill_BlazingArc",
			UltimateNameKey = "Ult_Dawnburst",
			Color = Color3.fromRGB(255, 130, 40),
			SkillCooldown = 6,
			SkillDamage = 20,
			UltimateDamage = 60,
			SkillRange = 10,
			SkillWidth = 10,
			SkillWidthRank2 = 14,
			BurnDuration = 3,
			BurnDurationRank2 = 5,
			BurnTickDamage = 4,
			UltimateRadius = 14,
		},
		Lightning = {
			NameKey = "Affinity_Lightning",
			SkillNameKey = "Skill_ThunderStep",
			UltimateNameKey = "Ult_ThunderVerdict",
			Color = Color3.fromRGB(90, 220, 255),
			SkillCooldown = 6,
			SkillDamage = 18,
			UltimateDamage = 70,
			DashDistance = 14,
			DashWidth = 5,
			ChainCount = 2,
			ChainRange = 12,
			ChainDamageFraction = 0.5,
			UltimateDistance = 12,
			UltimateRadius = 12,
		},
	} :: { [string]: AffinityConfig },
}

-- Rango (1, 2 o 3) según los puntos de maestría.
function Affinities.rankOf(points: number): number
	local rank = 1
	for index, threshold in Affinities.Ranks do
		if points >= threshold then
			rank = index
		end
	end
	return rank
end

return Affinities
