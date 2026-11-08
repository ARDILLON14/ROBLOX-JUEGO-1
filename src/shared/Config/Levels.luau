--!strict
-- Progresión (GDD v1 §7, aprobada). El nivel máximo se puede subir en futuras actualizaciones.

export type SpecialReward = {
	Type: "Affinity" | "Cosmetic",
	Id: string?,
}

local Levels = {
	MaxLevel = 20,
	BaseHealth = 100,
	HealthPerLevel = 10,
	DamagePerLevel = 0.04, -- +4 % de daño por nivel
	PotionsPerLevel = 1,
	MaxPotions = 10,
	SpecialRewards = {
		[5] = { Type = "Affinity" },
		[10] = { Type = "Cosmetic", Id = "Title_DawnSeeker" },
		[15] = { Type = "Cosmetic", Id = "Aura_AetherEmber" },
		[20] = { Type = "Cosmetic", Id = "Title_VerdantiaGuardian" },
	} :: { [number]: SpecialReward },
}

-- XP necesaria para pasar del nivel "level" al siguiente: 100 × level^1,5 (redondeado a decenas).
function Levels.xpToNext(level: number): number
	return math.floor(100 * level ^ 1.5 / 10 + 0.5) * 10
end

-- Vida máxima en un nivel.
function Levels.maxHealth(level: number): number
	return Levels.BaseHealth + Levels.HealthPerLevel * (level - 1)
end

return Levels
